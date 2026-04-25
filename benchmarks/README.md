# Benchmarking popular Ruby JSON Serializers with Transmutation

Transmutation provides a very simple and elegant DSL that outperforms the majority of other serializers on the market. It also boasts consistent performance with small standard deviation.

\* _Benchmarks were ran on a MacBook Pro M1 Pro with the following Ruby version:_ `ruby 3.2.5 (2024-07-26 revision 31d0f1a2e7) +YJIT [arm64-darwin24]`

The following objects are used for serialization:

```ruby
organisation = Organisation.new(id: 1, name: "Example Inc.") # Serialize with no associations
user = User.new(id: 1, first_name: "John", last_name: "Doe", organisation_id: 1) # Serialize with many Posts
post = Post.new(id: 1, title: "Sample Post", body: "Sample Body", user_id: 1) # Serialize with one User
organisations = [organisation] + 29.times.map { Organisation.new(id: _1 + 2, name: "Example Inc. #{_1 + 2}") }
```

## Results

### Attributes

| Gem                                                                                       | IPS                | Comparison   | Allocations | Comparison |
|-------------------------------------------------------------------------------------------|--------------------|--------------|-------------|------------|
| [alba 3.6.0](https://github.com/okuramasafumi/alba)                                       |    473.982k ± 1.6% |     baseline |      1.128k | 1.11x more |
| [panko_serializer 0.8.3](https://github.com/yosiat/panko_serializer)                      |    337.389k ±10.6% | 1.40x slower |      1.016k |   baseline |
| [transmutation 0.5.1](https://github.com/spellbook-technology/transmutation)              |    314.398k ± 9.2% | 1.51x slower |      1.040k | 1.02x more |
| [active_model_serializers 0.10.15](https://github.com/rails-api/active_model_serializers) |    202.110k ± 3.6% | 2.35x slower |      1.992k | 1.96x more |
| [representable 3.2.0](https://github.com/trailblazer/representable/)                      |    157.150k ± 3.2% | 3.02x slower |      4.304k | 4.24x more |
| [rabl 0.17.0](https://github.com/nesquena/rabl)                                           |    105.862k ± 5.3% | 4.48x slower |      5.856k | 5.76x more |
| [jbuilder 2.13.0](https://github.com/rails/jbuilder/tree/v2.13.0)                         |     88.011k ± 6.6% | 5.39x slower |      2.208k | 2.17x more |

<details>
  <summary>JSON Output:</summary>

  ```json
  {"id":1,"name":"Example Inc.","logo_url":"https://example.com/logos/companies/1"}
  ```
</details>

### Has One / Belongs To

| Gem                                                                                       | IPS                | Comparison   | Allocations | Comparison |
|-------------------------------------------------------------------------------------------|--------------------|--------------|-------------|------------|
| [alba 3.6.0](https://github.com/okuramasafumi/alba)                                       |    214.622k ± 1.2% |     baseline |      1.912k |   baseline |
| [transmutation 0.5.1](https://github.com/spellbook-technology/transmutation)              |    168.840k ± 1.5% | 1.27x slower |      2.288k | 1.20x more |
| [panko_serializer 0.8.3](https://github.com/yosiat/panko_serializer)                      |    127.328k ± 4.2% | 1.69x slower |      4.128k | 2.16x more |
| [representable 3.2.0](https://github.com/trailblazer/representable/)                      |     81.974k ± 2.5% | 2.62x slower |      6.184k | 3.23x more |
| [active_model_serializers 0.10.15](https://github.com/rails-api/active_model_serializers) |     62.949k ± 1.3% | 3.41x slower |      5.840k | 3.05x more |
| [rabl 0.17.0](https://github.com/nesquena/rabl)                                           |     57.561k ± 3.3% | 3.73x slower |      9.608k | 5.03x more |
| [jbuilder 2.13.0](https://github.com/rails/jbuilder/tree/v2.13.0)                         |     43.080k ± 2.3% | 4.98x slower |      3.856k | 2.02x more |

<details>
  <summary>JSON Output:</summary>

  ```json
  {"id":1,"title":"Sample Post","body":"Sample Body","user":{"id":1,"first_name":"John","full_name":"John Doe"}}
  ```
</details>

### Has Many

| Gem                                                                                       | IPS                | Comparison   | Allocations | Comparison |
|-------------------------------------------------------------------------------------------|--------------------|--------------|-------------|------------|
| [panko_serializer 0.8.3](https://github.com/yosiat/panko_serializer)                      |    223.232k ± 2.5% |     baseline |      1.376k |   baseline |
| [alba 3.6.0](https://github.com/okuramasafumi/alba)                                       |    160.667k ± 1.1% | 1.39x slower |      2.440k | 1.77x more |
| [transmutation 0.5.1](https://github.com/spellbook-technology/transmutation)              |    124.635k ± 3.4% | 1.79x slower |      3.656k | 2.66x more |
| [representable 3.2.0](https://github.com/trailblazer/representable/)                      |     53.158k ± 1.2% | 4.20x slower |      9.640k | 7.01x more |
| [active_model_serializers 0.10.15](https://github.com/rails-api/active_model_serializers) |     43.965k ± 3.7% | 5.08x slower |      8.728k | 6.34x more |
| [jbuilder 2.13.0](https://github.com/rails/jbuilder/tree/v2.13.0)                         |     43.513k ± 2.8% | 5.13x slower |      4.704k | 3.42x more |
| [rabl 0.17.0](https://github.com/nesquena/rabl)                                           |     28.359k ± 1.2% | 7.87x slower |     10.912k | 7.93x more |

<details>
  <summary>JSON Output:</summary>

  ```json
  {"id":1,"first_name":"John","full_name":"John Doe","posts":[{"id":1,"title":"Post 1","body":"Sample body 1"},{"id":3,"title":"Post 3","body":"Sample body 3"}]}
  ```
</details>

### Collection

| Gem                                                                                       | IPS                | Comparison    | Allocations | Comparison  |
|-------------------------------------------------------------------------------------------|--------------------|---------------|-------------|-------------|
| [panko_serializer 0.8.3](https://github.com/yosiat/panko_serializer)                      |     69.118k ± 1.1% |      baseline |      7.616k |    baseline |
| [alba 3.6.0](https://github.com/okuramasafumi/alba)                                       |     26.113k ± 1.2% |  2.65x slower |     15.911k |  2.09x more |
| [transmutation 0.5.1](https://github.com/spellbook-technology/transmutation)              |     20.735k ± 1.2% |  3.33x slower |     28.183k |  3.70x more |
| [rabl 0.17.0](https://github.com/nesquena/rabl)                                           |     11.969k ± 1.1% |  5.77x slower |     21.527k |  2.83x more |
| [active_model_serializers 0.10.15](https://github.com/rails-api/active_model_serializers) |      7.514k ± 3.3% |  9.20x slower |     69.927k |  9.18x more |
| [jbuilder 2.13.0](https://github.com/rails/jbuilder/tree/v2.13.0)                         |      5.589k ±18.9% | 12.37x slower |     32.662k |  4.29x more |
| [representable 3.2.0](https://github.com/trailblazer/representable/)                      |      4.953k ± 1.0% | 13.96x slower |    160.543k | 21.08x more |

<details>
  <summary>JSON Output:</summary>

  ```json
  [{"id":1,"name":"Example Inc.","logo_url":"https://example.com/logos/companies/1"},{"id":2,"name":"Example Inc. 2","logo_url":"https://example.com/logos/companies/2"},{"id":3,"name":"Example Inc. 3","logo_url":"https://example.com/logos/companies/3"},{"id":4,"name":"Example Inc. 4","logo_url":"https://example.com/logos/companies/4"},{"id":5,"name":"Example Inc. 5","logo_url":"https://example.com/logos/companies/5"},{"id":6,"name":"Example Inc. 6","logo_url":"https://example.com/logos/companies/6"},{"id":7,"name":"Example Inc. 7","logo_url":"https://example.com/logos/companies/7"},{"id":8,"name":"Example Inc. 8","logo_url":"https://example.com/logos/companies/8"},{"id":9,"name":"Example Inc. 9","logo_url":"https://example.com/logos/companies/9"},{"id":10,"name":"Example Inc. 10","logo_url":"https://example.com/logos/companies/10"},{"id":11,"name":"Example Inc. 11","logo_url":"https://example.com/logos/companies/11"},{"id":12,"name":"Example Inc. 12","logo_url":"https://example.com/logos/companies/12"},{"id":13,"name":"Example Inc. 13","logo_url":"https://example.com/logos/companies/13"},{"id":14,"name":"Example Inc. 14","logo_url":"https://example.com/logos/companies/14"},{"id":15,"name":"Example Inc. 15","logo_url":"https://example.com/logos/companies/15"},{"id":16,"name":"Example Inc. 16","logo_url":"https://example.com/logos/companies/16"},{"id":17,"name":"Example Inc. 17","logo_url":"https://example.com/logos/companies/17"},{"id":18,"name":"Example Inc. 18","logo_url":"https://example.com/logos/companies/18"},{"id":19,"name":"Example Inc. 19","logo_url":"https://example.com/logos/companies/19"},{"id":20,"name":"Example Inc. 20","logo_url":"https://example.com/logos/companies/20"},{"id":21,"name":"Example Inc. 21","logo_url":"https://example.com/logos/companies/21"},{"id":22,"name":"Example Inc. 22","logo_url":"https://example.com/logos/companies/22"},{"id":23,"name":"Example Inc. 23","logo_url":"https://example.com/logos/companies/23"},{"id":24,"name":"Example Inc. 24","logo_url":"https://example.com/logos/companies/24"},{"id":25,"name":"Example Inc. 25","logo_url":"https://example.com/logos/companies/25"},{"id":26,"name":"Example Inc. 26","logo_url":"https://example.com/logos/companies/26"},{"id":27,"name":"Example Inc. 27","logo_url":"https://example.com/logos/companies/27"},{"id":28,"name":"Example Inc. 28","logo_url":"https://example.com/logos/companies/28"},{"id":29,"name":"Example Inc. 29","logo_url":"https://example.com/logos/companies/29"},{"id":30,"name":"Example Inc. 30","logo_url":"https://example.com/logos/companies/30"}]
  ```
</details>

## How to run the benchmarks yourself

In order to run the benchmarks, you'll need to have Ruby and Bundler installed on your system. Once you've installed all the dependencies with `bundle install`, you can run the benchmarks with or without YJIT enabled.

- Run the benchmarks without YJIT enabled

    ```sh
    bundle exec ruby benchmark.rb
    ```

- Run the benchmarks with YJIT enabled

    ```sh
    bundle exec ruby --yjit benchmark.rb
    ```
