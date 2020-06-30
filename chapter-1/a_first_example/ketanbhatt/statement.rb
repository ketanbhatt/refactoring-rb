# frozen_string_literal: true

require 'json'

require './statement_calculators'

def text_statement(invoice, plays)
  statement_data = calculate_statement(invoice, plays)

  lines = ["Statement for #{statement_data['customer']}"]

  statement_data[:performances].each do |perf|
    lines.push("  #{perf[:play_name]}: $#{perf[:amount] / 100} (#{perf[:audience]} seats)")
  end

  lines.push("Amount owed is $#{statement_data[:total_amount] / 100}")
  lines.push("You earned #{statement_data[:total_volume_credits]} credits")

  lines.join("\n")
end

def html_statement(invoice, plays)
  nil
end

plays_json = JSON.parse(File.read('./plays.json'))
invoices_json = JSON.parse(File.read('./invoices.json'))
result = text_statement(invoices_json.first, plays_json)
puts result