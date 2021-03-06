require "rubygems"
require "bundler"
require "rspec"
require "active_record"
require 'sidekiq/testing'
require "delayed_after_commit"
require 'byebug'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define :version => 0 do
  create_table(:users)  { |t| t.string :name; t.integer :number_of_updates; t.integer :number_of_letters_in_name }
end

class User < ActiveRecord::Base
  include DelayedAfterCommit
  attr_accessor :increment_enabled

  delayed_after_update :increment_number_of_updates, if: :increment_enabled
  delayed_after_create :calculate_number_of_letters_in_name

  protected
  def calculate_number_of_letters_in_name
    update_column('number_of_letters_in_name', self.name.size)
  end

  def increment_number_of_updates
    update_column('number_of_updates', self.number_of_updates.to_i + 1)
  end
end