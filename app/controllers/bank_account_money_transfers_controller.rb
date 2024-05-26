class BankAccountMoneyTransfersController < ApplicationController
  def create
    @bank_account_money_transfer = BankAccountMoneyTransfer.new(bank_account_money_transfer_params)

    respond_to |format|
      if @bank_account_money_transfer.save
        format.html { redirect_to @bank_account_money_transfer, notice: "The money was successfully transferred." }
        format.json { render :show, status: :created, location: @bank_account_money_transfer }
      else
        format.html { render :new }
        format.json { render json: @bank_account_money_transfer.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def bank_account_money_transfer_params
    params.require(:bank_account_money_transfer).permit(:from, :to_id, :amount, :currency)
  end
end
