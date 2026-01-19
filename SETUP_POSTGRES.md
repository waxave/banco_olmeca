# Fly.io PostgreSQL setup
#
# Run these commands to set up PostgreSQL for the app:

# 1. Create PostgreSQL volume
fly volumes create pg-volumen --region qro

# 2. Create PostgreSQL app
flyctl launch --image postgres:14 --no-deploy --name banco-olmeca-db --region qro --size shared-cpu-1x --vm-size shared-cpu-1x

# 3. Attach volume to PostgreSQL
flyctl volume attach pg-volumen --app banco-olmeca-db --region qro

# 4. Update fly.toml with PostgreSQL configuration
# (The fly.toml will need to be updated with the database URL)

# 5. Set database secrets
flyctl secrets set DATABASE_URL="postgresql://postgres:password@banco-olmeca-db.internal:5432/banco_olmeca_production"

# Alternative: Use Fly.io managed PostgreSQL
# flyctl postgres create --region qro --name banco-olmeca-db --vm-size shared-cpu-1x
# flyctl postgres attach --app banco-olmeca