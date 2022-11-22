require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = [] # Es un array de letras
    10.times { @letters << ("A".."Z").to_a.sample }
  end

  def score
    @word = params[:query]
    @letters = params[:letters].split('')
    @result = run_game(@word, @letters, Time.now, Time.now + 1.0)
  end

  private

  def attempt_check(attempt, grid)
    attempt_array = attempt.upcase.chars
    copy_grid = grid
    result = true
    attempt_array.each do |letter|
      if copy_grid.include?(letter) == false
        result = false
      else
        index = copy_grid.find_index(letter)
        copy_grid.delete_at(index)
      end
    end
    return result
  end

  def exist_dictonary(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    user_serialized = URI.open(url).read # esto almacena una variable pero no manipulable como hash
    user = JSON.parse(user_serialized) # lo transformamos a un hash
    if user["found"]
      return true
    else
      return false
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    points = 0
    time = (end_time - start_time.to_f).to_f
    in_grid = attempt_check(attempt, grid)
    in_dictionary = exist_dictonary(attempt)
    if in_grid && in_dictionary
      points += (attempt.size * 10) + (100 / time) # mientras mas largo mejor y menos tiempo mejor
      message = "Well Done!"
    elsif !in_grid # si es que no esta en grid
      message = "not in the grid"
    elsif in_grid && !in_dictionary # si es que no esta en el diccionario, pero si en el grid
      message = "not an english word"
    end
    # Entregamos resultados
    return { score: points, message: message, time: time }
  end
end
