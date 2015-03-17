# encoding: utf-8
require 'spec_helper'

describe ApplicationHelper do

  describe '#title' do
    it "returns the default title when @title does not exist" do
      helper.title.should == "Edools"
    end

    it "returns the default title + @title when @title exists" do
      @title = "Curso de Lean Startup"
      helper.title.should == "Curso de Lean Startup | Edools"
    end
  end

  describe '#em_real' do
    it "returns the value converted to R$" do
      helper.em_real(1000).should == "R$ 10,00"
      helper.em_real(100).should == "R$ 1,00"
      helper.em_real(10).should == "R$ 0,10"
      helper.em_real(1).should == "R$ 0,01"
    end
  end

  describe '#states' do
    it "returns the list of states of brazil" do
      helper.states.should == ["AC", "AL", "AM", "AP", "BA", "CE", "DF", 
      "ES", "GO", "MA", "MT", "MS", "MG", "PA", 
      "PB", "PR", "PE", "PI", "RJ", "RN", "RO", 
      "RS", "RR", "SC", "SE", "SP", "TO"]
    end
  end

end
