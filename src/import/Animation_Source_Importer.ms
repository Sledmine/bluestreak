-- Halo Custom Edition Anatimation Source Importer
-- (for 3ds Max v5+ and gmax v1.2)
-- Version 1.0.1
-- Created by LaikaGlove
-- Contributions by:
--
-- Sledmine
------------------------------------------------------------------------------------------------
-- Features:
-- - Import animations from any source model animation file
------------------------------------------------------------------------------------------------
--	Instructions: Click the "Load File" button and navigate to the
--	desired Animation source file. Select from the import options and press the
--	"Import Animation" button to import the model.
------------------------------------------------------------------------------------------------
-- Visit the project on GitHub (https://github.com/Sledmine/bluestreak)
------------------------------------------------------------------------------------------------
--	Copyright (C) 2019 Mark Rizzo (mailto:mrizzo2291@gmail.com)				
--	This program is free software; you can redistribute it and/or modify it	
--	under the terms of the GNU General Public License as published by the	
--	Free Software Foundation; either version 2 of the License, or (at your	
--	option) any later version. This program is distributed in the hope that	
--	it will be useful, but WITHOUT ANY WARRANTY; without even the implied	
--	warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See	
--	the GNU General Public License for more details. A full copy of this	
--	license is available at http://www.gnu.org/licenses/gpl.txt.			
------------------------------------------------------------------------------------------------

frame_count = 0
frame_rate = 0

actor_block_count = 0
actor_blocks = #()

node_list_checksum = 0
node_block_count = 0
node_blocks = #()

animation_frame_blocks = #()

in_file = undefined
in_name = undefined
fileRoot = ""
fileLoc = ""
maxver = maxVersion()

struct actor_block
(
	name = ""
)

struct node_block
(
	name = "",
	first_child_node_index = -1,
	next_sibling_node_index = -1,
	parent_node_index = -1
)

struct animation_frame_block
(
	animation_node_blocks = #()
)

struct animation_node_block
(
	translation= #(),
	rotation = #(),
	scale = 1.0
)

fn readStringValue =
(
	line = ""

	while not (eof in_file) do
	(
		firstChar = readChar in_file
		
		case firstChar of
		(
			"\r": 	-- return
			(
				skipToNextLine in_file
			)
			"\n": 	-- newline
			(
				-- the first character is a newline so we don't need to skip to the next line
				--skipToNextLine in_file
			)
			"": 	-- Whitespace
			(
				skipToNextLine in_file
			)
			";": 	-- Comment
			(
				skipToNextLine in_file
			)
			"/": 	-- Comment
			(
				skipToNextLine in_file
			)
			undefined: 	-- unknown
			(
				skipToNextLine in_file
			)
			default: 
			(
				line = firstChar + readLine in_file
				exit
			)
		)
	)
	
	line
)

fn readIntegerValue =
(
	readStringValue() as integer
)

fn readFloatValue =
(
	readStringValue() as float
)

fn read3DPointValue =
(
	value = readStringValue()
	values = filterString value "\t"
	
	x = values[1] as float
	y = values[2] as float
	z = values[3] as float
	
	[x,y,z]
)

fn readQuaternionValue =
(
	value = readStringValue()
	values = filterString value "\t"
	
	i = values[1] as float
	j = values[2] as float
	k = values[3] as float
	w = values[4] as float

	normalize (quat i j k w)
)

fn firstIndexOf array value =
(
	result = -1
	
	for i = 1 to array.count do
	(
		if array[i] == value then
		(
			result = i
			exit
		)
	)
	
	result
)

rollout roll "Animation Source Importer" width:408 height:164
(
	GroupBox grp_load "File" pos:[8,8] width:392 height:77 align:#left
	button load_button "Load File" pos:[77,22] width:122 height:29 align:#left
	button unload_button "Unload File" pos:[211,22] width:127 height:29 enabled:false align:#left
	label lbl_animation "Animation:" pos:[19,61] width:55 height:16 align:#left
	edittext edt_animation "" pos:[74,59] width:313 height:16 align:#left
	
	GroupBox grp_import "Import Button" pos:[8,89] width:392 height:54 align:#left
	button import_button "Import Animation" pos:[144,104] width:141 height:29 align:#left
	label lbl_version "v1.0.0" pos:[357,146] width:37 height:15 align:#left
	
	on roll open do
	(
		ClearListener()
		format "Using max version: %\n" (maxver[1] / 1000.0)
	)
	on roll close do
	(
		if in_file != undefined then
		(
			close in_file
		)
	)
	on unload_button pressed do
	(
		close in_file
		unload_button.enabled = false
		lbl_animation.enabled = false
		edt_animation.text = ""
		grp_import.enabled = false
		import_button.enabled = false
	)
	on load_button pressed do
	(
		in_name = getOpenFileName \
			caption: "Select Halo Animation File" \
			types: "JMA File (*.jma)|*.jma|JMM File (*.jmm)|*.jmm|JMO File (*.jmo)|*.jmo|JMR File (*.jmr)|*.jmr|JMT File (*.jmt)|*.jmt|JMW File (*.jmw)|*.jmw|JMZ File (*.jmz)|*.jmz|All Files (*.*)|*.*"
		
		if in_name != undefined then
		(
			in_file = openFile in_name mode:"r"
			if in_file == undefined then
			(
				messageBox "Error in opening file!" title:"File opening error"
			)
			else
			(
				print ("Opened File: " + in_name)
				
				seek in_file 0
				version = readStringValue()
				
				if version == "16392" then
				(
					start1 = timeStamp()
			
					frame_count = 0
					frame_rate = 0
					actor_block_count = 0
					actor_blocks = #()
					node_list_checksum = 0
					node_block_count = 0
					node_blocks = #()

					unload_button.enabled = true
					import_button.enabled = true
					edt_animation.text = in_name
							
					print ("-------------------------------------------------------")
					
					frame_count = readIntegerValue()
					print ("Frame Count: " + frame_count as string)
					
					frame_rate = readIntegerValue()
					print ("Frame Rate: " + frame_rate as string)

					
					actor_block_count = readIntegerValue()
					print ("Actor Blocks: " + actor_block_count as string)
					
					for a = 1 to actor_block_count do
					(
						actor_blocks[a] = actor_block()
						
						actor_blocks[a].name = readStringValue()
					)

					node_block_count = readIntegerValue()
					print ("Node Blocks: " + node_block_count as string)
					
					node_list_checksum = readIntegerValue()
					print ("Node List Checksum: " + node_list_checksum as string)
					
					for n = 1 to node_block_count do
					(
						node_blocks[n] = node_block()
						
						node_blocks[n].name = readStringValue()
						node_blocks[n].first_child_node_index = readIntegerValue()
						node_blocks[n].next_sibling_node_index = readIntegerValue()
						node_blocks[n].parent_node_index = -1
					)
					
					-- Step through the child nodes and set the parent
					for n = 1 to node_block_count do
					(
						local first_child_index = node_blocks[n].first_child_node_index
						
						if first_child_index != -1 then
						(
							node_blocks[first_child_index + 1].parent_node_index = n - 1
						)
					)
					
					-- Step through the sibling nodes and set the parent
					for n = 1 to node_block_count do
					(
						local next_sibling_index = node_blocks[n].next_sibling_node_index
						
						if next_sibling_index != -1 then
						(
							node_blocks[next_sibling_index + 1].parent_node_index = node_blocks[n].parent_node_index
						)
					)
					
					for f = 1 to frame_count do
					(
						animation_frame_blocks[f] = animation_frame_block()
						
						for n = 1 to node_block_count do
						(
							animation_frame_blocks[f].animation_node_blocks[n] = animation_node_block()
							
							animation_frame_blocks[f].animation_node_blocks[n].translation = read3DPointValue()
							animation_frame_blocks[f].animation_node_blocks[n].rotation = readQuaternionValue()
							animation_frame_blocks[f].animation_node_blocks[n].scale = readFloatValue()
						)
					)
					
					print ("-------------------------------------------------------")
					
					end1 = timeStamp()
					print ("Animation indexing took " + ((end1 - start1) as float / 1000.0) as string + " seconds")
				)
				else
				(
					messageBox "Error: Incorrect file type!\n\nPlease select a valid animation source file.  " \
						title:"Incorrect file type error"
				)

				close in_file
			)
		)
	)
	on import_button pressed do
	(
		warningString = "Warning: The following issues may require your attention:  \n\n"
		missingNodes = #()
		show_warning = false
		
		max tool animmode
		set animate on
		
		animationRange = interval 0 (frame_count-1)
		
		for f = 1 to frame_count do
		(
			for n = 1 to node_block_count do
			(
				temp_node = getNodeByName (node_blocks[n].name)
				
				if temp_node != undefined then
				(
					nodeRotation = quat -animation_frame_blocks[f].animation_node_blocks[n].rotation.x -animation_frame_blocks[f].animation_node_blocks[n].rotation.y -animation_frame_blocks[f].animation_node_blocks[n].rotation.z animation_frame_blocks[f].animation_node_blocks[n].rotation.w
					nodeTranslation = animation_frame_blocks[f].animation_node_blocks[n].translation
					nodeScale = [animation_frame_blocks[f].animation_node_blocks[n].scale,animation_frame_blocks[f].animation_node_blocks[n].scale,animation_frame_blocks[f].animation_node_blocks[n].scale]
					
					addNewKey temp_node.rotation.controller (f - 1)
					at time (f - 1) (in coordsys parent temp_node.rotation = nodeRotation)
					addNewKey temp_node.position.controller (f - 1)
					at time (f - 1) (in coordsys parent temp_node.position = nodeTranslation)
					addNewKey temp_node.scale.controller (f - 1)
					at time (f - 1) (in coordsys parent temp_node.scale = nodeScale)
				)
				else
				(
					if (firstIndexOf missingNodes n) == -1 then
					(
						append missingNodes n
						warningString += "Couldn't find node '" + node_blocks[n].name + "' in scene.  \n"
						show_warning = true
					)
				)
			)
		)
		
		max tool animmode
		set animate off
		
		if show_warning == true then
		(
			if (queryBox (warningString + "\nProceed?") title:"Import caution") == true then
			(
				import_failed = false
			)
			else
			(
				import_failed = true
			)
		)
	)
)

CreateDialog roll
