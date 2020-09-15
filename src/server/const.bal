const ERROR_INVALID_FORMAT = "Invalid format in request body";
const ERROR_IN_WRITING = "Error in writing request byte stream to image";
const FAILED = "failed: ";

const CREATE_USER_INFO_TABLE = "CREATE TABLE IF NOT EXISTS users_info(id int NOT NULL AUTO_INCREMENT PRIMARY KEY, userID VARCHAR(255) UNIQUE, password VARCHAR(255));";
const string CREATE_RAW_DATA_TABLE = "CREATE TABLE IF NOT EXISTS raw_data(rawData VARCHAR(255));";
