export const config = {
  // Server Config
  ENV: process.env.ENV ?? "Development",
  PORT: process.env.PORT ?? 4000,
  UPLOAD_DIR: process.env.UPLOAD_DIR ?? "./uploads",
  MAX_FILE_SIZE_MB: process.env.MAX_FILE_SIZE_MB ?? 10,
  ALLOWED_FILE_EXTENSIONS:
    process.env.ALLOWED_FILE_EXTENSIONS ?? ".jpg;.jpeg;.png;.gif",
  PAGE_SIZE: parseInt(process.env.PAGE_SIZE ?? "10"),

  // Database config
  DB_USER: process.env.DB_USER ?? "admin",
  DB_PASSWORD: process.env.DB_PASSWORD ?? "StrongPassword",
  DB_HOST: process.env.DB_HOST ?? "localhost",
  DB_PORT: process.env.DB_PORT ?? "5432",
  DB_NAME: process.env.DB_NAME ?? "TesfaFundDB",

  // Auth0 config
  AUDIENCE: process.env.AUDIENCE ?? "",
  ISSUER_BASE_URL: process.env.ISSUER_BASE_URL ?? "",
  AUTH0_NAMESPACE:
    process.env.AUTH0_NAMESPACE ?? "https://tesfafund-api.example.com",
};
