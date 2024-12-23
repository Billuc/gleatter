//// This module exports types and functions related to the body of Routes

import gleam/dynamic
import gleam/json
import gleam/result
import gleam/string_tree
import gleatter

/// The type of body that can be expected from a Route
pub type BodyType {
  EmptyBody
  StringBody
  JsonBody
}

/// A wrapper for an encoder and a decoder to convert from request/response data to and from a Gleam type
pub type BodyConverter(body_type) {
  BodyConverter(
    encoder: fn(body_type) -> string_tree.StringTree,
    decoder: fn(String) -> Result(body_type, gleatter.GleatterError),
  )
}

/// The body type of a Route
pub opaque type RouteBody(body_type) {
  RouteBody(btype: BodyType, converter: BodyConverter(body_type))
}

/// Create a RouteBody that will be empty
pub fn empty_body() -> RouteBody(Nil) {
  RouteBody(
    EmptyBody,
    BodyConverter(
      fn(_) { string_tree.new() },
      //
      fn(_) { Ok(Nil) },
    ),
  )
}

/// Create a RouteBody that will be converted from/to json
pub fn json_body(
  encoder: fn(body_type) -> json.Json,
  decoder: fn(dynamic.Dynamic) -> Result(body_type, List(dynamic.DecodeError)),
) -> RouteBody(body_type) {
  RouteBody(
    JsonBody,
    BodyConverter(
      fn(value) { value |> encoder |> json.to_string_tree },
      //
      fn(body) {
        json.decode(from: body, using: decoder)
        |> result.map_error(fn(err) { gleatter.JsonDecodeError(err) })
      },
    ),
  )
}

/// Create a RouteBody that will be converted from/to a string
pub fn string_body(converter: BodyConverter(b)) -> RouteBody(b) {
  RouteBody(StringBody, converter)
}

/// Encode a value using the RouteBody's encoder into a StringBuilder
pub fn encode(body: RouteBody(b), value: b) -> string_tree.StringTree {
  value |> body.converter.encoder
}

/// Decode a value using the RouteBody's decoder from a String
pub fn decode(
  body: RouteBody(b),
  value: String,
) -> Result(b, gleatter.GleatterError) {
  value |> body.converter.decoder
}

/// Return the BodyType of a RouteBody
pub fn get_type(body: RouteBody(_)) -> BodyType {
  body.btype
}
