class StatementCalculator
  def initialize(play, performance)
    @play_id = play['play_id']
    @audience = performance['audience']
  end

  def amount
    raise NotImplementedError
  end

  def volume_credits
    [@audience - 30, 0].max
  end
end

class TragedyCalculator < StatementCalculator
  def amount
    result = 40_000
    result += 1000 * (@audience - 30) if @audience > 30

    result
  end
end

class ComedyCalculator < StatementCalculator
  def amount
    result = 30_000
    result += 10_000 + 500 * (@audience - 20) if @audience > 20
    result += 300 * @audience

    result
  end

  def volume_credits
    super + (@audience / 5).floor
  end
end


def get_calculator(play, performance)
  case play['type']
  when 'tragedy'
    TragedyCalculator.new(play, performance)
  when 'comedy'
    ComedyCalculator.new(play, performance)
  else
    raise Exception
  end
end

def calculate_statement(invoice, plays)
  statement_hash = { customer: invoice['customer'], performances: [] }

  total_amount = 0
  total_volume_credits = 0

  invoice['performances'].each do |perf|
    play_id = perf['playID']
    play = plays[play_id]

    calculator = get_calculator(play, perf)
    perf_statement = {
      play_id: play_id,
      play_name: play['name'],
      audience: perf['audience'],
      amount: calculator.amount,
      volume_credits: calculator.volume_credits,
    }

    total_amount += perf_statement[:amount]
    total_volume_credits += perf_statement[:volume_credits]

    statement_hash[:performances].push(perf_statement)
  end

  statement_hash.merge(
    total_amount: total_amount, total_volume_credits: total_volume_credits
  )
end
