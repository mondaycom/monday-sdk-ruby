# monday-sdk-ruby

Ruby SDK for developing over the monday.com platform

---

In order to use the APIs you need to have valid access token.
It could be short lived token received from JWT payload from Authorization header (valid for 60 seconds), or you could ask users for permanent [access token with OAuth](https://developer.monday.com/apps/docs/oauth).

## GraphQL API

All the future examples requires client instance with valid access token.

```ruby
token = "short lived access token or OAuth access token"
client = Monday::Client.new(token: token)

# you can pass a custom API endpoint
client = Monday::Client.new(token: token, api: 'https://custom.api.monday.com')

# or you can pass a custom Faraday client
connection = Faraday.new do |client|
  client.request :json
  client.response :raise_error
  client.response :json
end
client = Monday::Client.new(token: token, conn: connection)
```

For all available queries & mutations please see the documentation in the [Public API playground](https://monday.com/developers/v2/try-it-yourself)
For more references you can look at the [JavaScript SDK docs](https://developer.monday.com/apps/docs/mondayapi)

Simple query sample:

```ruby
client.api(%(
  query {
    me {
      name
    }
  }
))
```

Query with passed variables

```ruby
client.api(%(
  query ($boardId: Int) {
    boards(ids: [$boardId]) {
      id
      name
    }
  }
), variables: { boardId: 123_456 })
```

Mutation example

```ruby
client.api(%(
  mutation ($boardId: Int!, $title: String!) {
    create_column(
      board_id: $boardId
      title: $title
      column_type: text
    ) { id }
  }
), variables: { boardId: 123_456, title: 'Sample column' })
```

## GlobalStorage API

The most of the [JavaScript SDK documentation](https://developer.monday.com/apps/docs/mondaystorage#global-level) is relevant for Ruby.

The monday apps infrastructure includes a persistent, key-value storage that developers can leverage to store data without creating their own backend and maintaining their own database.
Storage doesn't reset between major versions since it is shared across the entire app, not just an instance.

The following limits apply to both the instance and global-level methods:

- Key length limit: 256
- Storage limit per key: 6MB

### Initializing global storage

The initializing process is the same as for the GraphQL API.

```ruby
storage = Monday::Storage.new(token: token)
```

### Set a new value

```ruby
storage.set('foo', 'test')
# => {'version' => '098f6'}

storage.set('foo', 'bar')
# => {'version' => '37b51'}
```

### Get a value:

```ruby
storage.get('foo')
# => {'value' => 'bar', 'version' => '37b51'}

storage.get('not-existed-key')
# => {'value' => nil}
```

### Delete an item:

```ruby
storage.get('foo')
# => {'value' => 'bar', 'version' => '37b51'}

storage.delete('foo')

storage.get('foo')
# => {'value' => nil}
```

### Versioning

`get` and `set` each return a version identifier you can use to identify the value currently stored in a key. Whenever a write that changes the value occurs, the version identifier in the database changes. The identifier signifies whether or not a value changed from another location and prevents it from being overwritten.

```ruby
  storage.get('foo')
  # => {'value' => 'bar', 'version' => '37b51'}
  begin
    storage.set('foo', {value: 'updated', previous_version: 'wrong'})
  rescue Faraday::ConflictError => exception
    # the value is not changed due to the version conflict
  end
```

If you want to not raise an exception, just pass your own instance of Faraday without the `raise_error` middleware:

```ruby
  connection = Faraday.new do |client|
    client.request :json
    client.response :json
  end
  storage = Monday::Storage.new(token: token, conn: connection)
```

### Access data created from the frontend

All the methods allow passing shared flag to access values scope accessible for current App's frontend instance.
Values created without this flag available only for the backend.
**Values saved with and without the flag are completely separated!**

```ruby
storage.get('foo')
# => {'value' => 'bar', 'version' => '1234a'}

storage.get('foo', shared: true)
# => {'value' => nil}

storage.set('foo', 'frontend', shared: true)
# => {'version' => 'aca33'}

storage.get('foo')
# => {'value' => 'bar', 'version' => '1234a'}

storage.get('foo', shared: true)
# => {'value' => 'frontend', 'version' => 'aca33'}
```
