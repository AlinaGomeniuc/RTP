# Lab1

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `lab1` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lab1, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/lab1](https://hexdocs.pm/lab1).


## Docker
```docker
docker pull alexburlacu/rtp-server
docker pull alinagomeniuc/rtp_lab1_forecast
docker run -p4000:4000 alexburlacu/rtp-server
docker run --network host -ti alinagomeniuc/rtp_lab1_forecast
```

