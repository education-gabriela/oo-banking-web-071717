class Transfer
  @@transactions = []

  attr_accessor :status, :sender, :receiver
  attr_reader :amount

  def initialize(sender, receiver, amount)
    @sender = sender
    @receiver = receiver
    @amount = amount
    @status = "pending"
  end

  def valid?
    self.sender.valid? && self.receiver.valid?
  end

  def execute_transaction
    action(self)
  end

  def reverse_transfer
    if self.status == "complete"
      sender = self.sender
      self.sender = self.receiver
      self.receiver = sender

      action(self)
      self.status = "reversed"
    end
  end

  def self.transaction_exists?(sender, receiver, amount)
    transaction = {
      :sender => sender,
      :receiver => receiver,
      :amount => amount
    }
    self.all.include?(transaction)
  end

  def self.all
    @@transactions
  end

  def self.print_all
    self.all.each do |transaction|
      puts transaction.inspect
    end
  end

  def action(transaction)
    if self.class.transaction_exists?(transaction.sender, transaction.receiver, transaction.amount)
      return
    elsif transaction.amount > transaction.sender.balance
      self.status = "rejected"
      return "Transaction rejected. Please check your account balance."
    end

    transaction.sender.balance -= transaction.amount
    transaction.receiver.balance += transaction.amount
    transaction.status = "complete"

    transaction.class.all << {
      :sender => transaction.sender,
      :receiver => transaction.receiver,
      :amount => transaction.amount
    }
  end
end
