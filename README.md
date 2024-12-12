# gleatter

[![Package Version](https://img.shields.io/hexpm/v/gleatter)](https://hex.pm/packages/gleatter)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gleatter/)

**Typed route definitions for seamless fullstack development !**

## Installation

```sh
gleam add gleatter
```

## Usage

```gleam
import gleatter
import gleatter/body
import gleatter/route
import gleatter/path
import gleatter/lustre as gleatter_lustre
import gleam/json
import gleam/dynamic
import gleam/http

pub type Todo {
  Todo(id: String, title: String)
}

fn encoder(t: Todo) -> json.Json {
  json.object([
    #("id", json.string(t.id)),
    #("title", json.string(t.title)),
  ])
}

fn decoder(
  value: dynamic.Dynamic,
) -> Result(Todo, List(dynamic.DecodeError)) {
  value
  |> dynamic.decode2(
    Todo,
    dynamic.field("id", dynamic.string),
    dynamic.field("title", dynamic.string),
  )
}

pub fn main() {
  let get_all_todos_route = route.new()
    |> with_path(path.static_path(["todos"]))
    |> with_response_body(body.json_body(encoder, decoder))

  // This route can be shared and used by both frontend and backend applications

  // Here is an example for a frontend lustre application using gleatter_lustre
  gleatter_lustre.create_factory()
    |> gleatter_lustre.with_port(2345)
    |> gleatter_lustre.for_route(get_all_todos_route)
    |> gleatter_lustre.with_path(Nil) // For now, this is necessary
    |> gleatter_lustre.send(
      fn(todos) { ServerSentTodos(todos) }, // ServerSentTodos is a Lustre message
      fn(_err) { effect.none() } // This is for error handling
    )
}
```

See also the `gleatter/service` module for easy route definitions.

Further documentation can be found at <https://hexdocs.pm/gleatter>.

## Features

- Route definitions with full type support
- Erlang and Javascript targets
- Easy service route definitions

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
