require File.expand_path(File.join(File.dirname(__FILE__), '..', 'plugin','identical_line_sequence.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper.rb'))

describe IdenticalLineSequence do

  before do
    @sequence = IdenticalLineSequence.new 2,6, ''
  end

  describe 'eviscerate' do

    it 'Can eviscerate, given a line number' do
      seq1, seq2 = @sequence.eviscerate 4
      seq1.start.should == 2
      seq1.finish.should == 3
      seq2.start.should == 5
      seq2.finish.should == 6
    end

    it 'Should only return one sequence if an outlying line is changed' do
      seq1, seq2 = @sequence.eviscerate 2
      seq1.should == nil
      seq2.start.should == 3
      seq2.finish.should == 6
    end

    it 'Returns 2 nils if a sequence gets destroyed' do
      small_seq = IdenticalLineSequence.new 1, 2, 'moo'
      seq1, seq2 = small_seq.eviscerate 1
      seq1.should be_nil
      seq2.should be_nil
    end

    it 'Returns 2 nils if a bigger sequence gets destroyed' do
      small_seq = IdenticalLineSequence.new 1, 3, 'moo'
      seq1, seq2 = small_seq.eviscerate 2
      seq1.should be_nil
      seq2.should be_nil
    end

    it 'Returns nils if the line eviscerate is out of bounds' do
      seq1, seq2 = @sequence.eviscerate 10
      seq1.should be_nil
      seq2.should be_nil
    end
  end

  describe 'cut' do
    it 'splits the sequence in two, without destroying the line' do
      seq1, seq2 = @sequence.cut 4
      seq1.start.should == 2
      seq1.finish.should == 3
      seq2.start.should == 4
      seq2.finish.should == 6
    end
  end

  describe 'grow' do
    it 'increments finish' do
      @sequence.grow
      @sequence.finish.should == 7
    end
  end

  describe 'shrink' do
    it 'decrements finish' do
      @sequence.shrink
      @sequence.finish.should == 5
    end
  end

  describe 'coalesce' do
    before do
      @other_seq = IdenticalLineSequence.new 6, 11, ''
    end

    it 'takes the finish from another sequence' do
      @sequence.coalesce @other_seq
      @sequence.start.should == 2
      @sequence.finish.should == 11
    end

    it 'should return itself' do
      @sequence.coalesce(@other_seq).should be_a IdenticalLineSequence
    end
  end

  describe 'moving' do

    it 'should decrement lines when moved up' do
      @sequence.move_up
      @sequence.start.should == 1
      @sequence.finish.should == 5
    end

    it 'should increment lines when moved up' do
      @sequence.move_down
      @sequence.start.should == 3
      @sequence.finish.should == 7
    end
  end


  describe 'contains_line?' do
    it 'works' do
      @sequence.contains_line?(3).should eql true
      @sequence.contains_line?(420).should eql false
    end
  end

  it 'can return itself as a range' do
    @sequence.range.should == (2..6)
  end

end
