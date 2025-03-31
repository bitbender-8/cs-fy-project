export const config = {
  // Server Config
  ENV: process.env.ENV ?? "Development",
  PORT: process.env.PORT ?? 4000,
  UPLOAD_DIR: process.env.UPLOAD_DIR ?? "./uploads",
  MAX_FILE_NO: parseInt(process.env.MAX_FILE_NO ?? "5"),
  MAX_FILE_SIZE_MB: process.env.MAX_FILE_SIZE_MB ?? 10,
  ALLOWED_MIME_TYPES:
    process.env.ALLOWED_MIME_TYPES ?? "image/jpeg;image/png;image/gif",
  ALLOWED_FILE_EXTENSIONS:
    process.env.ALLOWED_FILE_EXTENSIONS ?? ".jpg;.jpeg;.png;.gif",
  PAGE_SIZE: parseInt(process.env.PAGE_SIZE ?? "10"),
  ALLOWED_MAX_MONEY_AMOUNT: parseInt(
    process.env.ALLOWED_MAX_MONEY_AMOUNT ?? "100_000"
  ),

  // Database config
  DB_USER: process.env.DB_USER ?? "admin",
  DB_PASSWORD: process.env.DB_PASSWORD ?? "StrongPassword",
  DB_HOST: process.env.DB_HOST ?? "localhost",
  DB_PORT: parseInt(process.env.DB_PORT ?? "5432"),
  DB_NAME: process.env.DB_NAME ?? "TesfaFundDB",

  // Auth0 config
  AUTH0_NAMESPACE:
    process.env.AUTH0_NAMESPACE ?? "https://tesfafund-api.example.com",
  AUDIENCE: process.env.AUDIENCE ?? "CHANGE ME",
  ISSUER_BASE_URL: process.env.ISSUER_BASE_URL ?? "CHANGE ME",
  MANAGEMENT_ACCESS_TOKEN: process.env.MANAGEMENT_ACCESS_TOKEN ?? "CHANGE ME",
};
