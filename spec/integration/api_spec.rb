require "#{File.dirname(__FILE__)}/../spec_helper"

describe ScopedSearch, "API" do

  # This spec requires the API to be stable, so that projects using
  # scoped_search do not have to update their code if a new (minor)
  # version is released.
  #
  # API compatibility is only guaranteed for minor version changes;
  # New major versions may change the API and require code changes
  # in projects using this plugin.
  #
  # Because of the API stability guarantee, these spec's may only
  # be changed for new major releases.

  before(:all) do
    ScopedSearch::Spec::Database.establish_connection
  end

  after(:all) do
    ScopedSearch::Spec::Database.close_connection
  end

  context 'for unprepared ActiveRecord model' do

    it "should respond to :scoped_search to setup scoped_search for the model" do
      Class.new(ActiveRecord::Base).should respond_to(:scoped_search)
    end
  end

  context 'for a prepared ActiveRecord model' do

    before(:all) do
      @class = ScopedSearch::Spec::Database.create_model(:field => :string) do |klass|
        klass.scoped_search :on => :field
      end
    end

    after(:all) do
      ScopedSearch::Spec::Database.drop_model(@class)
    end

    it "should respond to :search_for to perform searches" do
      @class.should respond_to(:search_for)
    end

    it "should return an ActiveRecord::NamedScope::Scope when :search_for is called" do
      @class.search_for('query').class.should eql(ActiveRecord::NamedScope::Scope)
    end
  end

  context 'having backwards compatibility' do

    before(:each) do
      class Foo < ActiveRecord::Base
        belongs_to :bar
      end
    end

    after(:each) do
      Object.send :remove_const, :Foo
    end

    it "should respond to :searchable_on" do
      Foo.should respond_to(:searchable_on)
    end

    it "should create a Field instance for every argument" do
      ScopedSearch::Definition::Field.should_receive(:new).exactly(3).times
      Foo.searchable_on(:field_1, :field_2, :field_3)
    end

    it "should create a Field with a valid relation when using the underscore notation" do
      ScopedSearch::Definition::Field.should_receive(:new).with(
          instance_of(ScopedSearch::Definition), hash_including(:in => :bar, :on => :related_field))

      Foo.searchable_on(:bar_related_field)
    end

  end

end
