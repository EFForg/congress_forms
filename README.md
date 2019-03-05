# CongressForms


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'congress_forms'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install congress_forms


### Program Dependencies

  * google-chrome, git


## Usage

To send a message to Congress, begin by creating a form object. Senators should be identified by their [BioGuide ID](https://www.congress.gov/help/field-values/member-bioguide-ids), while Representatives are identified by an office code H*XXYY*, where XX is their state and YY is their district.

```ruby
# Form for Senator Kamala Harris (BioGuide H001075)
CongressForms::Form.find("H001075")

# Form for CA-13 Represenative Barbara Lee (office code HCA13)
CongressForms::Form.find("HCA13")
```

Each Senator's office may require different fields, provide different options for select menus, etc. You can query the fields required by a particular form by calling `CongressForms::Form#required_params`.

```ruby
# List required message parameters
irb(main)> CongressForms::Form.find("H001075").required_params
[
  # Required text fields
  { :value => "$NAME_FIRST", :max_length => nil },
  { :value => "$NAME_LAST", :max_length => nil },

  # Required multiple choice field
  { :value => "$NAME_PREFIX", :options => ["Mr.", "Ms.", "Mrs.", ...] },

  # Required multiple choice field with distinct labels and values
  {
    :value => "$TOPIC", :options => {
      "Abortion" => "943AD4D7-5056-A066-60A5-D652A671D70E",
      "Agriculture" => "943AD58A-5056-A066-60BD-A9DBEE1187A1",
      "Animal Welfare" => "943AD622-5056-A066-6065-1B45E2F6F45D",
    }
  },
 ...
]
...
```

Pass the required values, in a hash, to `CongressForms::Form#fill` to send the message.

```ruby
form = CongressForms::Form.find("H001075")

form.fill(
  "$NAME_FIRST" => "...",
  "$NAME_LAST" => "...",
  "$MESSAGE" => "...",
  ...
)
```

For Senate offices, this will fill out the representative's contact form with a headless instance of Google Chrome. For House offices, messages are submitted through the Communicating with Congress (CWC) API.


### CLI Usage

You can also send messages from the command line:

```
$ bin/congress_forms --help
Usage: congress_forms [options]
    -i, --rep_id REP_ID              ID of the representative to message
    -r, --repo DIR                   Location for unitedstates/contact_congress repository
    -p, --param KEY=VALUE            e.g. -p NAME_FIRST=Badger
```


## Operation and Configuration

Senate messages rely on contact form details tracked by the [unitedstates/contact-congress](https://github.com/unitedstates/contact-congress) project. This repo is cloned into a temporary directory by default. You can configure CongressForms to use an existing/persistent direcory with

```ruby
CongressForms.contact_congress_repository = "data/contact_congress"
```

A `git pull` is performed every now and then in this direcory, to keep the form details up to date. You can disable this behavior with

```ruby
CongressForms.auto_update_contact_congress = false
```

House messages are submitted through the [Communicating with Congress](https://www.house.gov/doing-business-with-the-house/communicating-with-congress-cwc) API. To send messages to the House, you will need to complete the vendor application process, then configure the API client with

```ruby
Cwc::Client.configure(
  api_key: ENV["CWC_API_KEY"],
  host: ENV["CWC_HOST"],
  delivery_agent: ENV["CWC_DELIVERY_AGENT"],
  delivery_agent_ack_email: ENV["CWC_DELIVERY_AGENT_ACK_EMAIL"],
  delivery_agent_contact_name: ENV["CWC_DELIVERY_AGENT_CONTACT_NAME"],
  delivery_agent_contact_email: ENV["CWC_DELIVERY_AGENT_CONTACT_EMAIL"],
  delivery_agent_contact_phone: ENV["CWC_DELIVERY_AGENT_CONTACT_PHONE"]
)
```

### CWC Concerns

The CWC API requires that you connect from a whitelisted IP address. This is true even for the test endpoint, which makes development and testing of the API client tricky.

If you have a whitelisted IP, you can use SSH port forwarding to tunnel requests to CWC through the approved server. Keep this command running in a console:

```
$ ssh -L [port]:test-cwc.house.gov:443 [server]
```

Use `https://localhost:[port]/` as your CWC host, and define these environment variables:

```
CWC_VERIFY_SSL=false
CWC_HOST_HEADER=test-cwc.house.gov
```

(substitute `[server]` and `[port]` with your own values)

### Disabling headless mode

Chrome can be run in windowed mode by setting the environment variable `HEADLESS=0`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/efforg/congress_forms.


## License

The gem is available as open source under the terms of the [GPLv3 License](https://github.com/EFForg/congress_forms/blob/master/LICENSE.txt).

