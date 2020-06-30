class PlayTypeBaseStatementCalculator
  def initialize(play_id:, audience:)
    @play_id = play_id
    @audience = audience
  end

  def amount
    raise NotImplementedError
  end

  def volume_credits
    raise NotImplementedError
  end
end

class TragedyStatementCalculator < PlayTypeBaseStatementCalculator
  def amount
    fixed_charge = 40_000
    total_additional_charge = 0

    included_attendee_count = 30
    charge_per_extra_person = 1000

    if @audience > included_attendee_count
      extra_attendee = @audience - included_attendee_count
      total_additional_charge += charge_per_extra_person * extra_attendee
    end

    fixed_charge + total_additional_charge
  end

  def volume_credits
    min_attendee_count = 30

    @audience > min_attendee_count ? @audience - 30 : 0
  end
end

class ComedyStatementCalculator < PlayTypeBaseStatementCalculator
  def amount
    fixed_charge = 30_000
    additional_charge_per_person = 300
    total_additional_charge = additional_charge_per_person * @audience

    included_attendee_count = 20
    charge_per_extra_person = 500
    additional_fixed_charge_if_extra_attendee = 10_000

    if @audience > included_attendee_count
      extra_attendee = @audience - included_attendee_count
      total_additional_charge += (charge_per_extra_person * extra_attendee) + additional_fixed_charge_if_extra_attendee
    end

    fixed_charge + total_additional_charge
  end

  def volume_credits
    min_attendee_count = 30
    extra_credit_for_every_n_attendee = 5

    credits = @audience > min_attendee_count ? @audience - 30 : 0
    credits += (@audience / extra_credit_for_every_n_attendee).floor

    credits
  end
end


def get_calculator(play, performance)
  audience = performance['audience']
  play_id = performance['play_id']

  case play['type']
  when 'tragedy'
    TragedyStatementCalculator.new(play_id: play_id, audience: audience)
  when 'comedy'
    ComedyStatementCalculator.new(play_id: play_id, audience: audience)
  else
    raise Exception
  end
end

def calculate_statement(invoice, plays)
  statement_hash = { performances: [] }

  invoice['performances'].each do |performance|
    play_id = performance['playID']
    play = plays[play_id]

    calculator = get_calculator(play, performance)

    statement_hash[:performances].push(
      {
        play_id: play_id,
        play_name: play['name'],
        audience: performance['audience'],
        amount: calculator.amount,
        volume_credits: calculator.volume_credits,
      }
    )
  end

  statement_hash[:customer] = invoice['customer']
  statement_hash[:total_amount] = statement_hash[:performances].reduce(0) { |sum, perf| sum + perf[:amount] }
  statement_hash[:total_volume_credits] = statement_hash[:performances].reduce(0) { |sum, perf| sum + perf[:volume_credits] }

  statement_hash
end
