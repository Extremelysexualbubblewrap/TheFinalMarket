class ContentFilter
  PROFANITY_PATTERNS = [
    /\b(bad|offensive|words|go|here)\b/i,
    # Add more patterns as needed
  ]

  SPAM_PATTERNS = [
    /\b(buy|cheap|discount|sale|offer).*(www|http|\.com)\b/i,
    /\b(earn|money|income|profit).*(online|fast|easy)\b/i
    # Add more patterns as needed
  ]

  def self.contains_profanity?(text)
    PROFANITY_PATTERNS.any? { |pattern| text.match?(pattern) }
  end

  def self.likely_spam?(text)
    SPAM_PATTERNS.any? { |pattern| text.match?(pattern) }
  end

  def self.analyze_text(text)
    {
      contains_profanity: contains_profanity?(text),
      likely_spam: likely_spam?(text),
      confidence: calculate_confidence(text)
    }
  end

  def self.should_flag?(text)
    result = analyze_text(text)
    result[:contains_profanity] || (result[:likely_spam] && result[:confidence] > 0.7)
  end

  private

  def self.calculate_confidence(text)
    spam_matches = SPAM_PATTERNS.count { |pattern| text.match?(pattern) }
    profanity_matches = PROFANITY_PATTERNS.count { |pattern| text.match?(pattern) }
    
    total_patterns = SPAM_PATTERNS.size + PROFANITY_PATTERNS.size
    matches = spam_matches + profanity_matches
    
    (matches.to_f / total_patterns).clamp(0, 1)
  end
end