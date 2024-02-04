import { AppConfig, DatabaseConfig, ObservabilityConfig } from "./appConfig";
import dotenv from "dotenv";
import { logger } from "../config/observability";
import { IConfig } from "config";

export const getConfig: () => Promise<AppConfig> = async () => {
    // Load any ENV vars from local .env file
    if (process.env.NODE_ENV !== "production") {
        dotenv.config();
    }

    // Load configuration after Azure KeyVault population is complete
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const config: IConfig = require("config") as IConfig;
    const databaseConfig = config.get<DatabaseConfig>("database");
    const observabilityConfig = config.get<ObservabilityConfig>("observability");

    if (!databaseConfig.connectionString) {
        logger.warn("database.connectionString is required but has not been set. Ensure environment variable 'AZURE_COSMOS_CONNECTION_STRING' has been set");
    }

    if (!observabilityConfig.connectionString) {
        logger.warn("observability.connectionString is required but has not been set. Ensure environment variable 'APPLICATIONINSIGHTS_CONNECTION_STRING' has been set");
    }

    return {
        observability: {
            connectionString: observabilityConfig.connectionString,
            roleName: observabilityConfig.roleName,
        },
        database: {
            connectionString: databaseConfig.connectionString,
            databaseName: databaseConfig.databaseName,
        },
    };
};