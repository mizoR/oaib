# oaib

`oaib` is a CLI client for managing OpenAI Batch operations, designed to make it easier to monitor the status of registered batches. When dealing with a large number of batches, the web dashboard can become difficult to navigate. This CLI simplifies filtering batch statuses, exporting information in JSONL format, and customizing outputs using tools like `jq`.

**Note: This project is currently under development and has not been officially released. Features and functionality are subject to change.**

## Installation
Since `oaib` is not yet published to Rubygems, you can install it directly from the source:
```bash
git clone https://github.com/mizoR/oaib.git
cd oaib

bundle config set path 'vendor/bundle'
./bin/setup
```

## Usage

### Setting Up
To use `oaib`, ensure you have your OpenAI API access token ready. You can run the CLI with the following environment variable:
```bash
OPENAI_ACCESS_TOKEN=__YOUR_TOKEN__ bundle exec bash
```

### Running Commands
Once the setup is complete, you can execute commands like:
```bash
bash$ ./exe/oaib --help
```

### Listing Batches
Use the `list` command to display batches based on filters such as status or creation time.

#### Example
```bash
bash$ ./exe/oaib list --before batch_67568fdbdfc8 --status completed | jq -r -f jq/simple.jq
batch_6758ffeda4bc  completed       224/224 0       2024-12-11T02:58:53Z    2024-12-11T03:14:45Z
batch_6757e4657048  completed       232/232 0       2024-12-10T06:49:09Z    2024-12-10T07:24:08Z
batch_6756bac14370  completed       175/175 0       2024-12-09T09:39:13Z    2024-12-09T10:00:02Z
batch_6756babf5abc  completed       384/384 0       2024-12-09T09:39:11Z    2024-12-09T19:39:27Z
```

### Customizing Output with jq
Exported JSONL data can be processed with `jq` for tailored outputs. For example:

#### Example
```bash
bash$ ./exe/oaib list --status completed | jq '{id, status}'
{
  "id": "batch_6758ffeda4bc",
  "status": "completed"
}
{
  "id": "batch_6757e4657048",
  "status": "completed"
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mizoR/oaib.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
