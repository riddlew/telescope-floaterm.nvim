local has_telescope, telescope = pcall(require, "telescope")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local log = require("log").log
local previewers = require("telescope.previewers.buffer_previewer")

if not has_telescope then
	error("This plugin requires nvim-telescope/telescope.nvim")
end

local function create_finder()
	local results = {}

	local bufs = vim.fn['floaterm#buflist#gather']() -- { 10, 12, 14 }
	for _, v in ipairs(bufs) do
		table.insert(results, {
			name = vim.fn['floaterm#window#make_title'](v, '$1'),
			title = vim.fn.getbufvar(v, 'floaterm_title'),
			buffer = v,
			-- type = 'floaterm'
		})
	end

	return finders.new_table({
		results = results,
		entry_maker = function(entry)
			local make_display = function()
				local title = entry.title
				if title == "floaterm($1/$2)" then
					title = "<No Name>"
				end

				local name = string.format("%s ", entry.name)
				local line = string.format("%-5s ", name) .. title
				local highlights = {}
				local hl_start = 6
				local hl_end = #line
				local bufnum_hl = Config.hl_groups.bufnum
				local title_hl = Config.hl_groups.title
				table.insert(highlights, { { 0, hl_start - 1 }, bufnum_hl })
				table.insert(
					highlights,
					{ { hl_start, hl_end }, title_hl }
				)
				return line, highlights
			end
			return {
				value = entry,
				ordinal = entry.name,
				name = entry.name,
				path = entry.path,
				display = make_display,
			}
		end,
	})
end

local function create_previewer(opts)
	return previewers.new_buffer_previewer {
		title = "Floaterm Preview",

		get_buffer_by_name = function(_, entry)
			return vim.fn.getbufvar(entry.value.buffer, 'name')
		end,

		define_preview = function(self, entry)
			local bufcontents = vim.api.nvim_buf_get_lines(entry.value.buffer, 0, -1, false)
			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, bufcontents)
		end
	}
end

local function do_action(prompt_buffer)
	local selection = action_state.get_selected_entry()
	if not selection then
		return
	end
	local entry = selection.value

	actions.close(prompt_buffer)
	vim.fn['floaterm#terminal#open_existing'](entry.buffer)

	-- if entry.type == "floaterm" then
	-- 	vim.fn['floaterm#terminal#open_existing'](entry.buffer)
	-- else
	-- 	vim.fn['floaterm#run']('new', '!0', { '', 0, '', '' }, '')
	-- end
end

local function picker(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "Floaterm",
			finder = create_finder(),
			sorter = conf.generic_sorter(opts),
			previewer = create_previewer(opts),
			preview = {
				hide_on_startup = false
			},
			attach_mappings = function(_, map)
				-- map("n", "<C-d>", delete_path)
				-- map("i", "<C-d>", delete_path)
				actions.select_default:replace(do_action)
				return true
			end,
		})
		:find()
end

return telescope.register_extension({ exports = { floaterm = picker } })
