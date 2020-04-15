def stockPicker_bruteForce(daily_prices)
        buy_day = 0
        best_buy_day = nil
        best_sell_day = nil
        best_profit = 0
        while buy_day < daily_prices.length() - 1 do
                sell_day = buy_day + 1
                while sell_day < daily_prices.length() do
                        profit = daily_prices[sell_day] - daily_prices[buy_day]
                        if profit > best_profit
                                best_profit = profit
                                best_buy_day = buy_day
                                best_sell_day = sell_day
                        end
                        sell_day += 1
                end
                buy_day += 1
        end

        puts "The best day to buy is day number #{best_buy_day + 1}. You'd best sell on day #{best_sell_day + 1} for #{best_profit}$ profit. Days total: #{daily_prices.length()}."
        return nil
end

stockPicker_bruteForce([33, 4, 12, 5,5, 23, 32, 45,2, 2, 34])
stockPicker_bruteForce([17,3,6,9,15,8,6,1,10])
stockPicker_bruteForce([666,1,3,3,34,45,4,23,6,43]) #edge case: highest price: day 0
stockPicker_bruteForce([23,34,234,456,756,8,1]) #edge case: lowest price: last day
stockPicker_bruteForce([666,232,32, 12, 534, 1]) #edge case: both
stockPicker_bruteForce([1,2,3,4,5,6,7,8,9])
