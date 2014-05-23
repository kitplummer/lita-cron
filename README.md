# lita-cron

A Lita handler for a cron-based message scheduler. Allows you to
create, list and delete scheduled messages - using standard
cron-line notation.  Uses lita's redis backing to persist scheduled
deliveries through a lita restart (just recreates jobs from db.)

## Installation

Add lita-answers to your Lita instance's Gemfile:

``` ruby
gem "lita-cron"
```

## Usage

*CREATE* `@bot cron new 15 15 * * 1-5 @all Submit your timecard`

*LIST* `@bot cron list`  

*DELETE* `@bot cron delete @all Submit your timecard`  

## License

[MIT](http://opensource.org/licenses/MIT)
