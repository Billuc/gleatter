import gleam/json

/// Errors that can occur in Gleatter code
pub type GleatterError {
  RouteError(msg: String)
  JsonDecodeError(err: json.DecodeError)
}
