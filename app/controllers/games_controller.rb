require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    @letters = (1..10).to_a.map{|number| ("A".."Z").to_a[rand(0..25)] }
  end

  def score
    @grid = params[:grid]
    @answer = params[:answer]
    @answer_is_english = word_is_correct?(@answer)
    @answer_in_grid = word_in_the_grid?(@answer, @grid)
    @score = results(@answer, @answer_is_english, @answer_in_grid)
    session["score"] == nil ? session["score"] = @answer_is_english : session["score"] += @answer_is_english if @answer_is_english
  end

  private

  def word_is_correct?(answer)
    url = "https://wagon-dictionary.herokuapp.com/#{answer.downcase}"
    return JSON.parse(open(url).read)["found"] ? JSON.parse(open(url).read)["length"] : false
  end

  def word_in_the_grid?(answer, grid)
    letter_used = answer.upcase.split("").map { |letter| grid.include?(letter) }.include?(false)
    letter_duplicate = answer.upcase.split("").map { |letter| answer.upcase.chars.count(letter) <= grid.count(letter) ? true : false}.include?(false)
    return !letter_used && !letter_duplicate
  end

  def results(answer, answer_is_english, answer_in_grid)
    if answer_is_english && answer_in_grid
      "Your score is #{answer_is_english}"
    elsif answer_in_grid
      "Your word '#{answer}' does not exist"
    elsif answer_is_english
      "Your word '#{answer}' is not in the grid"
    else
      "Your word '#{answer}' is not english and not in the grid"
    end
  end
end
