module TransferHelper
  def operation_color(operation)
    operation.account_id == current_user.id ? '#fd938b' : '#7bdce4'
  end
end
