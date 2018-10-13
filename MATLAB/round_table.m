function rounded_table = round_table(input_table,number_of_digits)
   
  rounded_table = input_table;
  number_of_variables = size(input_table,2);
  
  for i = 1:number_of_variables
      if isfloat(input_table{:,i})
          rounded_table{:,i} = round(input_table{:,i},number_of_digits);
      end
  end


end