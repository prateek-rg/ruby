def get_cell_value(cell)
	($grid[cell[1].to_i][cell[0].ord - 65] || '0').to_i
end

def set_cell_value(cell, value)
	$grid[cell[1].to_i][cell[0].ord - 65] = value
end


def print_grid
	$grid.size.times do |row_num|
		$grid[row_num].size.times do |col_num|
			print ($grid[row_num][col_num] || 0).to_s + ' '
		end
		puts
	end
end

def remove_expression_at(cell)
	expression = $expressions_hash[cell.to_sym]
	$expressions_hash.delete(cell)
	$dependants_hash[expression[0].to_sym].delete(cell)
	$dependants_hash[expression[1].to_sym].delete(cell)
end

#evaluates expressions tree at each cell in a breadth first fashion
def evaluate_expression_at(cells)
	while cells.size > 0 do
		cell = cells[0]
		expression = $expressions_hash[cell.to_sym]	

=begin
		Remove current dependant cell as it is being processed.
		Please note that we do not want to use .delete to 
		avoid deleting the same dependancy from further down the dependancy tree
=end

		cells.shift

		#add child dependancies to the array to be evaluated later
		cells.concat $dependants_hash[cell.to_sym] if $dependants_hash[cell.to_sym]

		cell_value_1 = get_cell_value(expression[0])
		cell_value_2 = get_cell_value(expression[1])

		#evaluate current expression
		case expression[2]
			when '*'
			set_cell_value(cell, cell_value_1 * cell_value_2)
			when '**'
			set_cell_value(cell, cell_value_1 ** cell_value_2)
			when '+'
			set_cell_value(cell, cell_value_1 + cell_value_2)
			when '-'
			set_cell_value(cell, cell_value_1 - cell_value_2)
			when '/'
			set_cell_value(cell, cell_value_1 / cell_value_2)
		end
	end
end

def add_dependants_recursive(cell, deps)
	if $dependants_hash[cell.to_sym]
		$dependants_hash[cell.to_sym].each do |dep|
			deps.push(dep)
			add_dependants_recursive(dep, deps)
		end
	end
	deps
end	

def prompt_set_value
	puts "Enter a value. Use Syntax <Column> = <value>. For e.g. D5 = 5. Do mind the spaces on either side of '='"
	command = gets.chomp
	puts command
	if command.match(/^[A-J][0-9] = (\d+)$/)
		cell, value = command.split(' = ')

		#remove any expression if already present at cell
		remove_expression_at(cell) if $expressions_hash[cell.to_sym]

		set_cell_value(cell, value.to_i)
		evaluate_expression_at $dependants_hash[cell.to_sym] if $dependants_hash[cell.to_sym]
		print_grid
		prompt_for_action
	else
		puts "Not a valid value command"
		prompt_set_value
	end

end

def prompt_set_expression
	puts "Enter an expression. Use Syntax <Column> = <Column> <operator> <Column>. For e.g. D5 = A5 + B5. Mind the spaces"
	command = gets.chomp
	puts command
	if command.match(/^[A-J][0-9] = [A-J][0-9] [+|-|*|**] [A-J][0-9]$/)
		operator = command[/[+|-|*|**]/]

		dest_cell, expression = command.split(' = ')
		source_cell_1, source_cell_2 = expression.split(' ' + operator + ' ')

		dest_cell_dependants = []
		add_dependants_recursive(dest_cell, dest_cell_dependants)
		unless dest_cell_dependants.include?(source_cell_1) || dest_cell_dependants.include?(source_cell_2)

			#remove any expression if already present at dest_cell
			remove_expression_at(dest_cell) if $expressions_hash[dest_cell.to_sym]

			$expressions_hash[dest_cell.to_sym] = [source_cell_1, source_cell_2, operator];
			
			[source_cell_1, source_cell_2].each do |source_cell|
				if $dependants_hash[source_cell.to_sym]
					$dependants_hash[source_cell.to_sym].push(dest_cell)
				else
					$dependants_hash[source_cell.to_sym] = [dest_cell]
				end
			end
				
			evaluate_expression_at([dest_cell])

			print_grid
			prompt_for_action
		else
			puts "Cyclic dependency found! Try again"
			prompt_set_expression
		end
	else
		puts "Not a valid value command"
		prompt_set_expression
	end
end

def prompt_for_action
	puts "Choose an action by typing the line number."	
	puts "1. Set Value"
	puts "2. Set Expression"
	puts "3. Exit"

	case gets.chomp
	when '1'
		prompt_set_value
	when '2'
		prompt_set_expression
	when '3'
		Kernel.exit(1)
	else
		puts "Please enter a valid line number"
		prompt_for_action
	end
end

grid_size = 10
$grid = Array.new(10) {Array.new(10)}
=begin
$expressions_hash has all the expressions to be evaludated against each cell.
The expression will be stored as [source_cell_1, source_cell_2, expression]
For e.g., a single expression command C0 = A0 + B0 will result in
{C0: ['A0','B0','+']}
=end
$expressions_hash = {}
=begin
$dependants_hash has the reference of dependants of a particular cell
For e.g., a single expression C0 = A0 + B0 will result in
{A0: ['C0'], B0: ['C0']}
=end
$dependants_hash = {}

prompt_for_action