# frozen_string_literal: true

require 'json'

def statement(invoice, plays)
  total_amount = 0
  volume_credits = 0
  result = "Statement for #{invoice['customer']}\n"

  invoice['performances'].each do |perf|
    play = plays[perf['playID']]

    this_amount = 0

    case play['type']
    when 'tragedy'
      this_amount = 40000
      if perf['audience'] > 30
        this_amount += 1000 * (perf['audience'] - 30)
      end
    when 'comedy'
      this_amount = 30000
      if perf['audience'] > 20
        this_amount += 10000 + 500 * (perf['audience'] - 20)
      end
      this_amount += 300 * perf['audience']
    else
      raise Exception("Unknown type: #{play['type']}")
    end

    volume_credits += [perf['audience'] - 30, 0].max
    # Add extra credit for every 10 comedy attendees
    if 'comedy' == play['type']
      volume_credits += (perf['audience'] / 5).floor
    end

    result += "  #{play['name']}: $#{this_amount / 100} (#{perf['audience']} seats)\n"
    total_amount += this_amount
  end

  result += "Amount owed is $#{total_amount / 100}\n"
  result += "You earned #{volume_credits} credits\n"
end

plays_json = JSON.parse(File.read("./plays.json"))
invoices_json = JSON.parse(File.read("./invoices.json"))
result = statement(invoices_json.first, plays_json)
puts result