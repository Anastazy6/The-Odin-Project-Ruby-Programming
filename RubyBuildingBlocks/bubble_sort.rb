def bubble_sort(array)
  swaps = nil
  until swaps == 0 do
    swaps = 0
    print "Repeating: \n"
    array.each_index do |x|
      break if array[x + 1].nil?

      next unless array[x] > array[x + 1]

      print "Swapping elements #{x} with #{x + 1}: #{array}\n => "
      swaps += 1
      temp = array[x]
      array[x] = array[x + 1]
      array[x + 1] = temp
      print "#{array} \n"
    end
  end
end

bubble_sort([1, 2, 5, 3, 4, 6, 9, 8, 7])

bubble_sort([5,3,8,3,55,32,21,32,21,3,6,8,9,90,56,666,23,46,23231,57,679,35,5768,23,12323,789,345,68,689,343,46,23,34457,56,8,34234,4566,2342,457,58568])