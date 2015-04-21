-- ---------------------------- Setup ----------------------------
StoryBook = LibStub("AceAddon-3.0"):NewAddon("StoryBook", "AceTimer-3.0")
StoryBook:SetDefaultModuleState(false)

if not StoryBookDB or not StoryBookDB.Output then 
	StoryBookDB = {};
	StoryBookDB.Enabled = false;
	StoryBookDB.Rate = 10;		--Ten seconds is usually a pretty smooth rate *winkyface*
	StoryBookDB.Output = 'console';
	StoryBookDB.OutputSpecial = '';
	StoryBookDB.Line = 0;
	StoryBookDB.LineCount = 0;
	StoryBookDB.Story = {};		--Current Story reference
	StoryBook.Story = {};		--Current Story
	StoryBook.List = {};
end

if not StoryBook.Stories then 
	StoryBook.Stories = {};
end

SLASH_StoryBook1 = "/story"
function SlashCmdList.StoryBook(msg, editbox)
	msg = strlower(msg)
	if (msg == "list") then
		print("|cFF6699CCStoryBook|r - List")
		StoryBook.ListStories()
	elseif (strsub(msg, 0, 3) == "set") then StoryBook.SetStory(strsub(msg,5));
	elseif (strsub(msg, 0, 6) == "output") then StoryBook.SetOutput(strsub(msg,8));
	elseif (strsub(msg, 0, 4) == "rate") then StoryBook.SetRate(strsub(msg,6));
	elseif (msg == "go" or msg == "start") then StoryBook.StartReading();
	elseif (msg == "stop" or msg == "pause") then StoryBook.StopReading();
	elseif (msg == "help output") then
		print("Any of the following after |cFFFFFF99'/story output '|r will change output.")
		print("battleground, emote, guild, officer, party, raid, raid_warning, say, yell")
		print("So |cFFFFFF99'/story output guild'|r will read the story in guild chat. Pretty self explanatory.")
		print("You can also whisper by using |cFFFFFF99'/story output whisper CoolPlayer'|r")
		print("Custom channels are |cFFFFFF99'/story output channel 2'|r where /2 is the channel you want.")
		print("If you don't want to share the story with other you can use '|cFFFFFF99/story output console|r' to speak only in your own chat window.");
	elseif (msg == "help") then
		print("|cFF6699CCStoryBook|r acceopts the following commands:");
		print("start/go - Both begin the story, paused or otherwise.");
		print("stop/pause - Pause the current story. You pick up again by using one of the above.");
		print("list - Lists all currently recognized stories and gives their index number.");
		print("set - Followed by a story name like Eternal or the number next to the story as it appears in list. Eg, '|cFFFFFF99/story set Eternal|r'");
		print("output - See |cFFFFFF99'/story help output'|r");
		print("help - shows this message.");
	else
		if (not StoryBookDB.Story or not StoryBookDB.Story.title) then
			print("|cFF6699CCStoryBook|r is inactive, to get started pick a story from the list below. ('|cFFFFFF99/story set [story name or number]|r')")
			StoryBook.ListStories()
			print("'|cFFFFFF99/story help|r' can explain more commands")
			print("Stories will be sent to "..StoryBookDB.Output..", see |cFFFFFF99'/story help output'|r for more options.");
		elseif (type(StoryBook.Timer) == "nil") then
			if (StoryBookDB.LineCount > 0 and StoryBookDB.LineCount <= StoryBookDB.Line) then
				print("|cFF6699CCStoryBook|r has finished this story, to start over use |cFFFFFF99'/story set'|r again.")
				print("Stories will be sent to "..StoryBookDB.Output..", see |cFFFFFF99'/story help output'|r for more options.");
			elseif (StoryBookDB.Line > 0) then
				print("|cFF6699CCStoryBook|r is paused on line "..StoryBookDB.Line.." |cFFFFFF99'/story go'|r to read.")
				print("Stories will be sent to "..StoryBookDB.Output..", see |cFFFFFF99'/story help output'|r for more options.");
			else
				print("|cFF6699CCStoryBook|r is ready to start reading \"|cFF6699CC"..StoryBookDB.Story.title.."|r\". Use |cFFFFFF99'/story go'|r to begin.")
				print("Stories will be sent to "..StoryBookDB.Output..", see |cFFFFFF99'/story help output'|r for more options.");
			end
		else
			print("|cFF6699CCStoryBook|r is currently reading \"|cFF6699CC"..StoryBookDB.Story.title.."|r\" and is on line "..StoryBookDB.Line..".")
			print("Stories will be sent to "..StoryBookDB.Output..", see |cFFFFFF99'/story help output'|r for more options.");
		end
	end
end

-- -------------------------- Ace Stuff --------------------------
function StoryBook.OnInitialize()
	StoryBook.Initialized = true;
	StoryBook.UpdateList();
end

function StoryBook.Enable()
	if (StoryBook.Initialized ~= true) then
		StoryBook.OnInitialize();
	end
	StoryBookDB.Enabled = true;
end
function StoryBook.Disable()
	StoryBookDB.Enabled = false;
end

-- ----------------------- Core Functions ------------------------
function StoryBook.UpdateList()
	wipe(StoryBook.List);
	StoryBook.List = {};
	for name, module in StoryBook:IterateModules() do
		StoryBook.AppendList(name, module);
	end
end

function StoryBook.AppendList(name, module)
	table.insert(StoryBook.List, ({entry = name, title = module.Title}));
end

function StoryBook.SetStory(story)
	local check = true;
	for i,v in pairs(StoryBook.List) do 
		if (strlower(v.title) == strlower(story)) then
			story = v;
			check = false;
			break;
		end
	end

	local num = tonumber(story);
	if check and num then
		if (StoryBook.List[num]) then
			story = StoryBook.List[num];
			check = false;
		end
	end
	
	if (check) then
		print("I couldn't find that story, try the number listed next to the story in '/story list' or make sure it's spelled the same way")
		return false;
	end
	
	StoryBookDB.Line = 0;
	StoryBookDB.LineCount = 0;
	StoryBookDB.Story = story;
	print("\"|cFF6699CC"..story.title.."|r\" is now the active story. Type |cFFFFFF99'/story go'|r to begin this tale.");
end

function StoryBook.StartReading()
	Story = StoryBook:GetModule(StoryBookDB.Story.entry);
	if (Story:IsEnabled() == false) then Story:Enable(); end
	StoryBookDB.LineCount = #(Story.Content);
	StoryBook.Story.content = Story.Content;
	StoryBook:CancelAllTimers();
	StoryBook.Timer = StoryBook:ScheduleRepeatingTimer("TimerCallback", tonumber(StoryBookDB.Rate));
	print("|cFF6699CCStoryBook|r Activated. Story will begin momentarily.");
end

function StoryBook.StopReading()
	StoryBook:CancelAllTimers();
	print("|cFF6699CCStoryBook|r Paused. To restart the story use |cFFFFFF99'/story set'|r again.");
end

function StoryBook.ListStories()
		print("------------------------------")
		for i,v in pairs(StoryBook.List) do print(i..": |cFF6699CC"..v.title); end
end

function StoryBook.TimerCallback()
	if (StoryBookDB.LineCount == StoryBookDB.Line) then StoryBook:CancelAllTimers(); end
	if (StoryBookDB.LineCount < StoryBookDB.Line) then 
		StoryBook:CancelAllTimers();
		print "|cFF6699CCStoryBook|r has finished this story, to start over or continue reading another story pick it using |cFFFFFF99'/story set'|r";
		return;
	end
	while (type(StoryBook.Story.content[StoryBookDB.Line]) == "nil" or StoryBook.Story.content[StoryBookDB.Line] == ".") do
		StoryBookDB.Line = StoryBookDB.Line + 1;
	end
	if StoryBookDB.Output == 'console' then	print(StoryBook.Story.content[StoryBookDB.Line]);
	elseif (StoryBookDB.Output == "whisper" or StoryBookDB.Output == "channel") then
		if (StoryBookDB.OutputSpecial == "") then 
			StoryBook:CancelAllTimers();
			print(StoryBookDB.Output.." target broken, please use |cFFFFFF99'/story output "..StoryBookDB.Output.." target'|r again");
			return;
		end
		SendChatMessage(StoryBook.Story.content[StoryBookDB.Line], StoryBookDB.Output, nil, StoryBookDB.OutputSpecial);
	else
		SendChatMessage(StoryBook.Story.content[StoryBookDB.Line], StoryBookDB.Output);
	end
	StoryBookDB.Line = StoryBookDB.Line + 1;
end


function StoryBook.SetOutput(target)
	local outputs = {"battleground", "emote", "guild", "officer", "party", "raid_warning", "raid", "say", "yell", "whisper", "channel", "console"};
	local output = false;
	for _,v in pairs(outputs) do
		if (strlower(strsub(target, 0, strlen(v))) == v) then
			output = v;
			print("Output set to "..output..".");
			break;
		end
	end
	
	if (output == false) then
		print("Unrecognized output.");
	else
		if output == "whisper" or output == "channel" then
			if strsub(target, strlen(output)+1) == "" then
				print("No "..output.." target was specified. Hafta add one after \""..output.."\".");
				return;
			end
			StoryBookDB.OutputSpecial = strsub(target, strlen(output)+1);
		end
		StoryBookDB.Output = output;
	end
end

function StoryBook.SetRate(rate)
	if (tonumber(rate) ~= nil) then 
		StoryBookDB.Rate = tonumber(rate);
		print("Rate set to one line every"..rate.." seconds.");
	else
		print("Rate is set at one line every"..StoryBookDB.Rate.." seconds.");
	end
end