-- ------MAKE SURE YOU EDIT the .TOC TOO!
local StoryBook = LibStub("AceAddon-3.0"):GetAddon("StoryBook")
local Story = StoryBook:NewModule('StoryBook_StoryName', 'AceEvent-3.0');
-- ------------------------------^Don't use spaces here^

-- -----------V Eg, My Little Dashie V
Story.Title = "Story Name";
StoryBook.AppendList(Story:GetName(), Story);

function Story:OnEnable()
-- -----------------Each line in your story needs to be wrapped in "s.
--					If it already has " the turn the actual " into \"
	Story.Content = {"This is my story By Me", "\"I like Pie\" I said.", "The End"};
end
function Story:OnDisable()
	Story.Content = {}
	wipe(Story.Content)
end