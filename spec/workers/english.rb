require 'rspec'

require_relative '../../lib/treat'
include Treat::Core::DSL

Treat.libraries.stanford.model_path = '/ruby/stanford/stanford-core-nlp-all/'
Treat.libraries.stanford.jar_path = '/ruby/stanford/stanford-core-nlp-all/'
Treat.libraries.punkt.model_path = '/ruby/punkt/'
Treat.libraries.reuters.model_path = '/ruby/reuters/'

class English

  $workers = Treat.languages.english.workers
  Treat.core.language.default = 'english'
  Treat.core.language.detect  = false

  describe Treat::Workers::Processors::Segmenters do

    before do
      @zones = ["Qala is first referred to in a fifteenth century portolan preserved at the Vatican library has taken its name from the qala or port of Mondoq ir-Rummien. It is the easternmost village of Gozo and has been inhabited since early times. The development of the present settlement began in the second half of the seventeenth century. It is a pleasant and rural place with many natural and historic attractions.",
      "Originally Radio Lehen il-Qala transmitted on frequency 106.5FM. But when consequently a national radio started transmissions on a frequency quite close, it caused a hindrance to our community radio." "People were complaining that the voice of the local radio was no longer clear and they were experiencing difficulty in following the programmes. This was a further proof of the value of the radio. It was a confirmation that it was a good and modern means of bringing the Christian message to the whole community. An official request was therefore made to the Broadcasting Authority and Radio Lehen il-Qala was given a new frequency - 106.3FM."]
      @groups = [
        ["Qala is first referred to in a fifteenth century portolan preserved at the Vatican library has taken its name from the qala or port of Mondoq ir-Rummien.", "It is the easternmost village of Gozo and has been inhabited since early times.", "The development of the present settlement began in the second half of the seventeenth century.", "It is a pleasant and rural place with many natural and historic attractions."],
        ["Originally Radio Lehen il-Qala transmitted on frequency 106.5FM.", "But when consequently a national radio started transmissions on a frequency quite close, it caused a hindrance to our community radio.", "People were complaining that the voice of the local radio was no longer clear and they were experiencing difficulty in following the programmes.", "This was a further proof of the value of the radio.", "It was a confirmation that it was a good and modern means of bringing the Christian message to the whole community.", "An official request was therefore made to the Broadcasting Authority and Radio Lehen il-Qala was given a new frequency - 106.3FM."]
      ]
    end
    it "should segment a zone into groups" do
      @zones.map { |zone| zone.segment }
      .map { |zone| zone.groups.map(&:to_s) }
      .should eql @groups
    end
  end

  describe Treat::Workers::Processors::Tokenizers do

    before do
      @groups = [
        "Julius Obsequens was a Roman writer who is believed to have lived in the middle of the fourth century AD.",
        "The only work associated with his name is the Liber de prodigiis (Book of Prodigies), completely extracted from an epitome, or abridgment, written by Livy; De prodigiis was constructed as an account of the wonders and portents that occurred in Rome between 249 BC-12 BC.",
        "Of great importance was the edition by the Basle Humanist Conrad Lycosthenes (1552), trying to reconstruct lost parts and illustrating the text with wood-cuts.",
        "These have been interpreted as reports of unidentified flying objects (UFOs), but may just as well describe meteors, and, since Obsequens, probably, writes in the 4th century, that is, some 400 years after the events he describes, they hardly qualify as eye-witness accounts.",
        '"At Aenariae, while Livius Troso was promulgating the laws at the beginning of the Italian war, at sunrise, there came a terrific noise in the sky, and a globe of fire appeared burning in the north.'
      ]
      @tokens = [
        ["Julius", "Obsequens", "was", "a", "Roman", "writer", "who", "is", "believed", "to", "have", "lived", "in", "the", "middle", "of", "the", "fourth", "century", "AD", "."],
        ["The", "only", "work", "associated", "with", "his", "name", "is", "the", "Liber", "de", "prodigiis", "(", "Book", "of", "Prodigies", ")", ",", "completely", "extracted", "from", "an", "epitome", ",", "or", "abridgment", ",", "written", "by", "Livy", ";", "De", "prodigiis", "was", "constructed", "as", "an", "account", "of", "the", "wonders", "and", "portents", "that", "occurred", "in", "Rome", "between", "249", "BC-12", "BC", "."],
        ["Of", "great", "importance", "was", "the", "edition", "by", "the", "Basle", "Humanist", "Conrad", "Lycosthenes", "(", "1552", ")", ",", "trying", "to", "reconstruct", "lost", "parts", "and", "illustrating", "the", "text", "with", "wood-cuts", "."],
        ["These", "have", "been", "interpreted", "as", "reports", "of", "unidentified", "flying", "objects", "(", "UFOs", ")", ",", "but", "may", "just", "as", "well", "describe", "meteors", ",", "and", ",", "since", "Obsequens", ",", "probably", ",", "writes", "in", "the", "4th", "century", ",", "that", "is", ",", "some", "400", "years", "after", "the", "events", "he", "describes", ",", "they", "hardly", "qualify", "as", "eye-witness", "accounts", "."],
        ["\"", "At", "Aenariae", ",", "while", "Livius", "Troso", "was", "promulgating", "the", "laws", "at", "the", "beginning", "of", "the", "Italian", "war", ",", "at", "sunrise", ",", "there", "came", "a", "terrific", "noise", "in", "the", "sky", ",", "and", "a", "globe", "of", "fire", "appeared", "burning", "in", "the", "north", "."]
      ]
    end

    it "should tokenize a group into tokens" do
      $workers.processors.tokenizers.each do |tokenizer|
        @groups.dup.map { |text| group(text).tokenize(tokenizer) }
        .map { |group| group.tokens.map(&:to_s) }
        .should eql @tokens
      end
    end
  end

  describe Treat::Workers::Processors::Parsers do
    before do
      @groups = ["A sentence to tokenize."]
      @phrases = [["A sentence to tokenize.", "A sentence", "to tokenize", "tokenize"]]
    end
    it "should tokenize and parse a group into tokens" do
      $workers.processors.parsers.each do |parser|
        @groups.dup.map { |text| group(text).parse(parser) }
        .map { |group| group.phrases.map(&:to_s)}
        .should eql @phrases
      end
    end
  end

  describe Treat::Workers::Lexicalizers::Taggers do
    before do
      @groups = ["I was running"]
      @group_tags = [["PRP", "VBD", "VBG"]]
      @tokens = ["running", "man", "2", ".", "$"]
      @token_tags = ["VBG", "NN", "CD", ".", "$"]
    end
    context "it is called on a group" do
      it "tags each token in the group and returns the tag 'G'" do
        $workers.lexicalizers.taggers.each do |tagger|
          @groups.map { |txt| group(txt).tag }
          .all? { |tag| tag == 'G' }.should be_true
          @groups.map { |txt| group(txt).tokenize }
          .map { |g| g.tokens.map(&:tag) }
          .should eql @group_tags
        end
      end
    end
    context "it is called on a token" do
      it "returns the tag of the token" do
        @tokens.map { |tok| token(tok).tag  }
        .should eql @token_tags
      end
    end
  end

  describe Treat::Workers::Lexicalizers::Sensers do
    before do
      @words = ["throw", "weak", "table", "furniture"]
      @hyponyms = [
        ["slam", "flap down", "ground", "prostrate", "hurl", "hurtle", "cast", "heave", "pelt", "bombard", "defenestrate", "deliver", "pitch", "shy", "drive", "deep-six", "throw overboard", "ridge", "jettison", "fling", "lob", "chuck", "toss", "skim", "skip", "skitter", "juggle", "flip", "flick", "pass", "shed", "molt", "exuviate", "moult", "slough", "abscise", "exfoliate", "autotomize", "autotomise", "pop", "switch on", "turn on", "switch off", "cut", "turn off", "turn out", "shoot", "demoralize", "perplex", "vex", "stick", "get", "puzzle", "mystify", "baffle", "beat", "pose", "bewilder", "disorient", "disorientate"],
        [],
        ["correlation table", "contents", "table of contents", "actuarial table", "statistical table", "calendar", "file allocation table", "periodic table", "altar", "communion table", "Lord's table", "booth", "breakfast table", "card table", "coffee table", "cocktail table", "conference table", "council table", "council board", "console table", "console", "counter", "desk", "dressing table", "dresser", "vanity", "toilet table", "drop-leaf table", "gaming table", "gueridon", "kitchen table", "operating table", "Parsons table", "pedestal table", "pier table", "platen", "pool table", "billiard table", "snooker table", "stand", "table-tennis table", "ping-pong table", "pingpong table", "tea table", "trestle table", "worktable", "work table", "dining table", "board", "training table"],
        ["baby bed", "baby's bed", "bedroom furniture", "bedstead", "bedframe", "bookcase", "buffet", "counter", "sideboard", "cabinet", "chest of drawers", "chest", "bureau", "dresser", "dining-room furniture", "etagere", "fitment", "hallstand", "lamp", "lawn furniture", "nest", "office furniture", "seat", "sectional", "Sheraton", "sleeper", "table", "wall unit", "wardrobe", "closet", "press", "washstand", "wash-hand stand"]
      ]
      @hypernyms =  [
        ["propel", "impel", "move", "remove", "take", "take away", "withdraw", "put", "set", "place", "pose", "position", "lay", "communicate", "intercommunicate", "engage", "mesh", "lock", "operate", "send", "direct", "upset", "discompose", "untune", "disconcert", "discomfit", "express", "verbalize", "verbalise", "utter", "give tongue to", "shape", "form", "work", "mold", "mould", "forge", "dislodge", "bump", "turn", "release", "be"],
        [],
        ["array", "furniture", "piece of furniture", "article of furniture", "tableland", "plateau", "gathering", "assemblage", "fare"],
        ["furnishing"]
      ]
      @antonyms = [[], ["strong"], [], []]
      @synonyms = [
        ["throw", "shed", "cast", "cast off", "shake off", "throw off", "throw away", "drop", "thrust", "give", "flip", "switch", "project", "contrive", "bewilder", "bemuse", "discombobulate", "hurl", "hold", "have", "make", "confuse", "fox", "befuddle", "fuddle", "bedevil", "confound"],
        ["weak", "watery", "washy", "unaccented", "light", "fallible", "frail", "imperfect", "decrepit", "debile", "feeble", "infirm", "rickety", "sapless", "weakly", "faint"],
        ["table", "tabular array", "mesa", "board"],
        ["furniture", "piece of furniture", "article of furniture"]
      ]
    end

    context "when form is set to 'hyponyms'" do
      it "returns the hyponyms of the word" do
        @words.map { |txt| word(txt) }
        .map(&:hyponyms).should eql @hyponyms
        @words.map { |txt| word(txt) }
        .map { |wrd| wrd.sense(nym: :hyponyms) }
        .should eql @hyponyms
      end
    end

    context "when form is set to 'hypernyms'" do
      it "returns the hyponyms of the word" do
        @words.map { |txt| word(txt) }
        .map(&:hypernyms).should eql @hypernyms
        @words.map { |txt| word(txt) }
        .map { |wrd| wrd.sense(nym: :hypernyms) }
        .should eql @hypernyms
      end
    end

    context "when form is set to 'antonyms'" do
      it "returns the hyponyms of the word" do
        @words.map { |txt| word(txt) }
        .map(&:antonyms).should eql @antonyms
        @words.map { |txt| word(txt) }
        .map { |wrd| wrd.sense(nym: :antonyms) }
        .should eql @antonyms
      end
    end

    context "when form is set to 'synonyms'" do
      it "returns the hyponyms of the word" do
        @words.map { |txt| word(txt) }
        .map(&:synonyms).should eql @synonyms
        @words.map { |txt| word(txt) }
        .map { |wrd| wrd.sense(nym: :synonyms) }
        .should eql @synonyms
      end
    end

  end

  describe Treat::Workers::Lexicalizers::Categorizers do

    before do
      @phrase = "I was running"
      @fragment = "world. Hello"
      @sentence = "I am running."
      @group_categories = ["phrase",
      "fragment", "sentence"]
      @tokens = ["running"]
      @token_tags = ["verb"]
    end

    context "when called on a group" do
      it "returns a tag corresponding to the group name" do
        $workers.lexicalizers.categorizers.each do |categorizer|
          [phrase(@phrase), fragment(@fragment), sentence(@sentence)]
          .map { |grp| grp.apply(:tag).category(categorizer) }
          .should eql @group_categories
        end
      end
    end

    context "when called on a tagged token" do
      it "returns the category corresponding to the token's tag" do
        $workers.lexicalizers.categorizers.each do |categorizer|
          @tokens.map { |tok| token(tok).apply(:tag).category(categorizer) }
          .should eql @token_tags
        end
      end
    end

  end

  describe Treat::Workers::Inflectors::Ordinalizers,
  Treat::Workers::Inflectors::Cardinalizers do

    before do
      @numbers = [1, 2, 3]
      @ordinal = ["first", "second", "third"]
      @cardinal = ["one", "two", "three"]
    end

    context "when ordinal is called on a number" do
      it "returns the ordinal form (e.g. 'first') of the number" do
        $workers.inflectors.ordinalizers.each do |ordinalizer|
          @numbers.map { |num| number(num) }
          .map { |num| num.ordinal(ordinalizer) }.should eql @ordinal
        end
      end
    end

    context "when cardinal is called on a number" do
      it "returns the cardinal form (e.g. 'second' of the number)" do
        $workers.inflectors.cardinalizers.each do |cardinalizer|
          @numbers.map { |num| number(num) }
          .map { |num| num.cardinal(cardinalizer) }.should eql @cardinal
        end
      end
    end

  end

  describe Treat::Workers::Inflectors::Stemmers do
    before do
      @words = ["running"]
      @stems = ["run"]
    end
    context "when called on a word" do
      it "annotates the word with its stem and returns the stem" do
        $workers.inflectors.stemmers.each do |stemmer|
          @words.map(&:stem).should eql @stems
        end
      end
    end
  end

  describe Treat::Workers::Extractors::NameTag do
    before do
      @groups = ["Obama and Sarkozy will meet in Berlin."]
      @tags = [["person", nil, "person", nil, nil, nil, "location", nil]]
    end
    
    context "when called on a group of tokens" do
      it "tags each token with its name tag" do
        $workers.extractors.name_tag.each do |tagger|
          @groups.map { |grp| grp.tokenize.apply(:name_tag) }
          .map { |grp| grp.tokens.map { |t| t.get(:name_tag) } }
          .should eql @tags
        end
      end
    end
    
  end

  describe Treat::Workers::Extractors::Topics do
    before do
      @files = ["./spec/workers/examples/english/test.txt"]
      @topics = [['household goods and hardware',
      'united states of america', 'corporate/industrial']]
    end
    context "when called on a tokenized document" do
      it "annotates the document with its general topics and returns them" do
        $workers.extractors.topics.each do |extractor|
          @files.map { |f| document(f).apply(:chunk, :segment, :tokenize) }
          .map { |doc| doc.topics }.should eql @topics
        end
      end
    end
  end
  
  describe Treat::Workers::Extractors::Time do
    before do
      @expressions = ["october 2006"]
      @months = [10]
    end
    context "when called on a group representing a time expression" do
      it "returns the DateTime object corresponding to the time" do
        $workers.extractors.time.each do |extractor|
          puts @expressions.map(&:time).inspect
          @expressions.map(&:time).all? { |time| time
            .is_a?(DateTime) }.should be_true
          @expressions.map(&:time).map { |time| time.month }
          .should eql @months
        end
      end
    end
  end
  
  describe Treat::Workers::Extractors::TopicWords do

    before do
      @collections = ["./spec/workers/examples/english/economist"]
      @topic_words = [["euro", "zone", "european", "mrs", "greece", "chancellor", "berlin", "practice", "german", "germans"], ["bank", "minister", "central", "bajnai", "mr", "hu", "orban", "commission", "hungarian", "government"], ["bank", "mr", "central", "bajnai", "prime", "government", "brussels", "responsibility", "national", "independence"], ["mr", "bank", "central", "policies", "prime", "minister", "today", "financial", "government", "funds"], ["euro", "merkel", "mr", "zone", "european", "greece", "german", "berlin", "sarkozy", "government"], ["mr", "bajnai", "today", "orban", "government", "forced", "independence", "part", "hand", "minister"], ["sarkozy", "mrs", "zone", "euro", "fiscal", "called", "greece", "merkel", "german", "financial"], ["mr", "called", "central", "policies", "financial", "bank", "european", "prime", "minister", "shift"], ["bajnai", "orban", "prime", "mr", "government", "independence", "forced", "commission", "-", "hvg"], ["euro", "sarkozy", "fiscal", "merkel", "mr", "chancellor", "european", "german", "agenda", "soap"], ["mr", "bank", "called", "central", "today", "prime", "government", "minister", "european", "crisis"], ["mr", "fiscal", "mrs", "sarkozy", "merkel", "euro", "summit", "tax", "leaders", "ecb"], ["called", "government", "financial", "policies", "part", "bank", "central", "press", "mr", "president"], ["sarkozy", "merkel", "euro", "mr", "summit", "mrs", "fiscal", "merkozy", "economic", "german"], ["mr", "prime", "minister", "policies", "government", "financial", "crisis", "bank", "called", "part"], ["mr", "bank", "government", "today", "called", "central", "minister", "prime", "issues", "president"], ["mr", "orban", "central", "government", "parliament", "hungarian", "minister", "hu", "personal", "bajnai"], ["government", "called", "central", "european", "today", "bank", "prime", "financial", "part", "deficit"], ["mr", "orban", "government", "hungarian", "bank", "hvg", "minister", "-", "fidesz", "hand"], ["mr", "bank", "european", "minister", "policies", "crisis", "government", "president", "called", "shift"]]
    end

    context "when #topic_words is called on a chunked, segmented and tokenized collection" do
      it "annotates the collection with the topic words and returns them" do
        $workers.extractors.topic_words.each do |extractor|
          @collections.map(&method(:collection))
          .map { |col| col.apply(:chunk,:segment,:tokenize) }
          map { |col| col.topic_words }.should eql @topic_words
        end
      end
    end
  end
  
  describe Treat::Workers::Inflectors::Conjugators do
    before do
      @infinitives = ["run"]
      @participles = ["running"]
    end
    
    context "when #present_participle is called on a word or #conjugate " +
    "is called on a word with option :form set to 'present_participle'" do
      it "returns the present participle form of the verb" do
        $workers.inflectors.conjugators.each do |conjugator|
          @participles.map { |verb| verb
          .infinitive(conjugator) }
          .should eql @infinitives
          @participles.map { |verb| verb.conjugate(
          conjugator, form: 'infinitive') }
          .should eql @infinitives
        end
      end
    end
    
    context "when #infinitive is called on a word or #conjugate is " +
    "called on a word with option :form set to 'infinitive'" do
      it "returns the infinitive form of the verb" do
        $workers.inflectors.conjugators.each do |conjugator|
          @infinitives.map { |verb| verb
          .present_participle(conjugator) }
          .should eql @participles
          @infinitives.map { |verb| verb.conjugate(
          conjugator, form: 'present_participle') }
          .should eql @participles
        end
      end
    end
    
  end
  
  describe Treat::Workers::Inflectors::Declensors do
    before do
      @singulars = ["man"]
      @plurals = ["men"]
    end
    context "when #plural is called on a word or #declense "+
    "is called on a word with option :count set to ''" do
      it "returns the plural form of the word" do
        $workers.inflectors.declensors.each do |declensor|
          @singulars.map { |word| word.plural(declensor) }
          .should eql @plurals
          @singulars.map { |word| word
          .declense(declensor, count: 'plural') }
          .should eql @plurals
        end
      end
    end
    context "when #singular is called on a word or #declense " +
    "is called on a word with option :count set to 'singular'" do
      it "returns the singular form of the word" do
        $workers.inflectors.declensors.each do |declensor|
          next if declensor == :linguistics
          @plurals.map { |word| word.singular(declensor) }
          .should eql @singulars
          @singulars.map { |word| word
          .declense(declensor, count: 'singular') }
          .should eql @singulars
        end
      end
    end
  end
end
