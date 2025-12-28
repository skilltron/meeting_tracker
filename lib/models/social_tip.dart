class SocialTip {
  final String id;
  final String category;
  final String mnemonic;
  final String tip;
  final String explanation;
  
  SocialTip({
    required this.id,
    required this.category,
    required this.mnemonic,
    required this.tip,
    required this.explanation,
  });
  
  static List<SocialTip> getAllTips() {
    return [
      // Conversation Skills
      SocialTip(
        id: 'pause-pour',
        category: 'Conversation',
        mnemonic: 'Pause Before You Pour',
        tip: 'Take a breath before responding; avoid interrupting',
        explanation: 'Gives you time to process and shows you\'re listening',
      ),
      SocialTip(
        id: 'one-thing',
        category: 'Focus',
        mnemonic: 'One Thing, One Time',
        tip: 'Focus on one conversation at a time',
        explanation: 'Reduces overwhelm and improves connection',
      ),
      SocialTip(
        id: 'ask-assume',
        category: 'Communication',
        mnemonic: 'Ask, Don\'t Assume',
        tip: 'Clarify if you missed something instead of guessing',
        explanation: 'Prevents misunderstandings and shows care',
      ),
      SocialTip(
        id: 'repeat-remember',
        category: 'Memory',
        mnemonic: 'Repeat to Remember',
        tip: 'Paraphrase what you heard to confirm understanding',
        explanation: 'Reinforces memory and shows active listening',
      ),
      SocialTip(
        id: 'interest-first',
        category: 'Conversation',
        mnemonic: 'Interest First, Then Share',
        tip: 'Ask about them before sharing your own stories',
        explanation: 'Builds rapport and prevents one-sided conversations',
      ),
      SocialTip(
        id: 'validate-add',
        category: 'Conversation',
        mnemonic: 'Validate, Then Add',
        tip: 'Acknowledge their point before adding yours',
        explanation: 'Shows you heard them before sharing your thoughts',
      ),
      
      // Body Language & Presence
      SocialTip(
        id: 'eyes-here',
        category: 'Body Language',
        mnemonic: 'Eyes = I\'m Here',
        tip: 'Make brief eye contact to show engagement',
        explanation: 'Signals attention even if your mind wanders',
      ),
      SocialTip(
        id: 'body-talks',
        category: 'Body Language',
        mnemonic: 'Body Talks, Words Follow',
        tip: 'Use open body language (uncrossed arms, face the person)',
        explanation: 'Non-verbal cues help maintain connection',
      ),
      SocialTip(
        id: 'fidget-friendly',
        category: 'Body Language',
        mnemonic: 'Fidget Friendly, Not Distracting',
        tip: 'Use subtle fidgets (pen, ring) that don\'t distract',
        explanation: 'Helps focus without appearing disengaged',
      ),
      SocialTip(
        id: 'phone-down',
        category: 'Presence',
        mnemonic: 'Phone Down, Person Up',
        tip: 'Put phone away during conversations',
        explanation: 'Shows respect and improves focus',
      ),
      
      // Energy & Boundaries
      SocialTip(
        id: 'energy-match',
        category: 'Energy',
        mnemonic: 'Energy Match, Don\'t Overwhelm',
        tip: 'Match the other person\'s energy level',
        explanation: 'Prevents coming across as too intense',
      ),
      SocialTip(
        id: 'time-check',
        category: 'Boundaries',
        mnemonic: 'Time Check, Don\'t Overstay',
        tip: 'Set a mental timer; know when to wrap up',
        explanation: 'Respects boundaries and prevents over-talking',
      ),
      SocialTip(
        id: 'exit-gracefully',
        category: 'Boundaries',
        mnemonic: 'Exit Gracefully',
        tip: 'Have a polite exit phrase ready ("I should let you go")',
        explanation: 'Helps end conversations without awkwardness',
      ),
      
      // Self-Care & Framing
      SocialTip(
        id: 'thank-not-sorry',
        category: 'Self-Talk',
        mnemonic: 'Thank You, Not Sorry',
        tip: 'Say "thanks for your patience" instead of "sorry I\'m late"',
        explanation: 'More positive framing, less self-deprecating',
      ),
      SocialTip(
        id: 'small-talk-big',
        category: 'Memory',
        mnemonic: 'Small Talk, Big Impact',
        tip: 'Remember one detail about people for next time',
        explanation: 'Shows you care and helps build relationships',
      ),
      
      // Additional Common Topics
      SocialTip(
        id: 'listen-to-understand',
        category: 'Communication',
        mnemonic: 'Listen to Understand, Not Reply',
        tip: 'Focus on understanding their perspective before formulating your response',
        explanation: 'Creates deeper connections and reduces miscommunication',
      ),
      SocialTip(
        id: 'space-respect',
        category: 'Boundaries',
        mnemonic: 'Space Respect, Don\'t Crowd',
        tip: 'Maintain comfortable physical distance',
        explanation: 'Shows respect for personal boundaries',
      ),
      SocialTip(
        id: 'tone-matters',
        category: 'Communication',
        mnemonic: 'Tone Matters More Than Words',
        tip: 'Pay attention to how you say things, not just what you say',
        explanation: 'Tone conveys emotion and intent more than words alone',
      ),
      SocialTip(
        id: 'name-power',
        category: 'Memory',
        mnemonic: 'Name Power - Use It',
        tip: 'Use people\'s names when greeting and saying goodbye',
        explanation: 'Makes interactions more personal and memorable',
      ),
      SocialTip(
        id: 'curiosity-over-judgment',
        category: 'Mindset',
        mnemonic: 'Curiosity Over Judgment',
        tip: 'Ask questions instead of making assumptions',
        explanation: 'Opens dialogue and prevents misunderstandings',
      ),
      SocialTip(
        id: 'pause-before-panic',
        category: 'Emotional Regulation',
        mnemonic: 'Pause Before Panic',
        tip: 'Take a moment before reacting to perceived social slights',
        explanation: 'Gives time to process and avoid overreaction',
      ),
      SocialTip(
        id: 'follow-up-follow-through',
        category: 'Relationships',
        mnemonic: 'Follow-Up, Follow Through',
        tip: 'If you say you\'ll do something, set a reminder to actually do it',
        explanation: 'Builds trust and shows reliability',
      ),
      SocialTip(
        id: 'share-space',
        category: 'Conversation',
        mnemonic: 'Share the Space, Don\'t Dominate',
        tip: 'Make sure both people get equal talking time',
        explanation: 'Creates balanced, enjoyable conversations',
      ),
      SocialTip(
        id: 'read-the-room',
        category: 'Social Awareness',
        mnemonic: 'Read the Room',
        tip: 'Notice if others seem tired, busy, or want to end the conversation',
        explanation: 'Shows empathy and social awareness',
      ),
      SocialTip(
        id: 'apologize-simply',
        category: 'Communication',
        mnemonic: 'Apologize Simply, Move Forward',
        tip: 'Brief, sincere apology, then focus on solution',
        explanation: 'Avoids over-apologizing and dwelling on mistakes',
      ),
      SocialTip(
        id: 'compliment-specific',
        category: 'Relationships',
        mnemonic: 'Compliment Specific, Not Generic',
        tip: 'Give specific compliments rather than vague ones',
        explanation: 'Shows genuine attention and feels more meaningful',
      ),
      SocialTip(
        id: 'boundaries-are-ok',
        category: 'Self-Care',
        mnemonic: 'Boundaries Are OK',
        tip: 'It\'s okay to say no or need alone time',
        explanation: 'Protecting your energy helps you be more present when you are social',
      ),
      SocialTip(
        id: 'mistakes-happen',
        category: 'Self-Compassion',
        mnemonic: 'Mistakes Happen, Learn and Move On',
        tip: 'Don\'t dwell on social mistakes; everyone makes them',
        explanation: 'Reduces anxiety and allows you to be more present',
      ),
      SocialTip(
        id: 'energy-budget',
        category: 'Self-Care',
        mnemonic: 'Energy Budget - Spend Wisely',
        tip: 'Plan social activities when you have energy, not when drained',
        explanation: 'Better interactions happen when you\'re at your best',
      ),
      SocialTip(
        id: 'prepare-topics',
        category: 'Conversation',
        mnemonic: 'Prepare Topics, Not Scripts',
        tip: 'Have a few conversation topics ready, but stay flexible',
        explanation: 'Reduces anxiety while keeping conversations natural',
      ),
      SocialTip(
        id: 'mirror-emotions',
        category: 'Empathy',
        mnemonic: 'Mirror Emotions, Match Energy',
        tip: 'Reflect back the emotional tone you\'re receiving',
        explanation: 'Shows empathy and helps people feel understood',
      ),
      SocialTip(
        id: 'silence-is-ok',
        category: 'Conversation',
        mnemonic: 'Silence Is OK, Don\'t Fill It',
        tip: 'Comfortable pauses are normal; you don\'t need to fill every gap',
        explanation: 'Reduces pressure and allows natural conversation flow',
      ),
      SocialTip(
        id: 'ask-open-questions',
        category: 'Conversation',
        mnemonic: 'Ask Open Questions, Not Yes/No',
        tip: 'Use "what" and "how" questions to encourage sharing',
        explanation: 'Creates more engaging, deeper conversations',
      ),
      SocialTip(
        id: 'remember-details',
        category: 'Memory',
        mnemonic: 'Remember Details, Write Them Down',
        tip: 'Jot down important details about people after meeting them',
        explanation: 'Helps you remember and shows you care next time',
      ),
      SocialTip(
        id: 'energy-levels',
        category: 'Self-Awareness',
        mnemonic: 'Know Your Energy Levels',
        tip: 'Recognize when you\'re overstimulated and need a break',
        explanation: 'Prevents social burnout and maintains quality interactions',
      ),
      SocialTip(
        id: 'follow-up-matters',
        category: 'Relationships',
        mnemonic: 'Follow-Up Matters',
        tip: 'Send a quick message after meeting someone new',
        explanation: 'Strengthens connections and shows interest',
      ),
    ];
  }
  
  static List<String> getAllCategories() {
    return [
      'Conversation',
      'Communication',
      'Body Language',
      'Memory',
      'Focus',
      'Boundaries',
      'Energy',
      'Self-Care',
      'Self-Talk',
      'Presence',
      'Mindset',
      'Emotional Regulation',
      'Relationships',
      'Social Awareness',
      'Self-Compassion',
      'Empathy',
      'Self-Awareness',
    ];
  }
}
