require 'test_helper'

class TransferControllerTest < ActionDispatch::IntegrationTest
  def setup
    @account_from = FactoryBot.create(:account, balance: 1000, email: 'from@example.com', password: 'pass1234')
    @account_to   = FactoryBot.create(:account, balance: 500, email: 'to@example.com', password: 'pass5678')
  end

  def log_in(account)
    post sessions_path, params: { account: { email: account.email, password: account.password } }
  end

  test 'can make a transfer between valid accounts and verifica movimientos y saldos' do
    log_in(@account_from)
    assert_equal @account_from.id, session[:account_id], 'Debe iniciar sesión correctamente'

    idempotency = SecureRandom.hex(10)
    transfer_params = {
      operation: {
        concept: 'Pago VERIFICACION',
        amount: 200,
        operation_account: @account_to.email,
        idempotency_key: idempotency
      }
    }

    assert_difference('Operation.where(account_id: @account_from.id).count', +1) do
      assert_difference('Operation.where(account_id: @account_to.id).count', +1) do
        assert_difference('@account_from.reload.balance', -200) do
          assert_difference('@account_to.reload.balance', +200) do
            post transfer_index_path, params: transfer_params
          end
        end
      end
    end

    @account_from.reload
    @account_to.reload
    assert_equal 800, @account_from.balance.to_i
    assert_equal 700, @account_to.balance.to_i

    # Ambas operaciones existen
    op_out = Operation.find_by(account_id: @account_from.id, idempotency_key: "#{idempotency}-out")
    op_in  = Operation.find_by(account_id: @account_to.id,   idempotency_key: "#{idempotency}-in")
    assert op_out, 'Debe existir operación salida en cuenta origen'
    assert op_in,  'Debe existir operación entrada en cuenta destino'
    assert_equal op_out.amount, op_in.amount
    assert_equal op_out.concept, op_in.concept
    assert_equal 'transfer', op_out.kind
    assert_equal 'transfer', op_in.kind

    assert_response :redirect
    follow_redirect!
    assert_match 'Transferencia realizada exitosamente', response.body
  end

  test 'idempotency evita doble transferencia' do
    log_in(@account_from)
    key = SecureRandom.hex(8)
    params_1 = {
      operation: {
        concept: 'Repetida',
        amount: 111,
        operation_account: @account_to.email,
        idempotency_key: key
      }
    }
    params_2 = params_1.deep_dup

    assert_difference('Operation.where(account_id: @account_from.id).count', +1) do
      assert_difference('Operation.where(account_id: @account_to.id).count', +1) do
        post transfer_index_path, params: params_1
        post transfer_index_path, params: params_2
      end
    end

    @account_from.reload
    @account_to.reload
    assert_equal 889, @account_from.balance.to_i
    assert_equal 611, @account_to.balance.to_i
  end

  test 'falla al transferir sin sesión' do
    transfer_params = {
      operation: {
        concept: 'Sin login',
        amount: 100,
        operation_account: @account_to.email
      }
    }
    post transfer_index_path, params: transfer_params
    assert_redirected_to new_session_path
  end
end
