
(function()

	---------------------------------
	-- New Opcode #500 (InvokeLua) --
	---------------------------------

	local IEex_InvokeLua = IEex_WriteOpcode({

		["ApplyEffect"] = {[[

			!build_stack_frame
			!sub_esp_byte 0C
			!push_registers

			!mov_esi_ecx

			; Copy resref field into null-terminated stack space ;
			!mov_eax_[esi+byte] 2C
			!mov_[ebp+byte]_eax F4
			!mov_eax_[esi+byte] 30
			!mov_[ebp+byte]_eax F8
			!mov_byte:[ebp+byte]_byte FC 0

			!lea_eax_[ebp+byte] F4
			!push_eax
			!push_dword *_g_lua
			!call >_lua_getglobal
			!add_esp_byte 08

			!push_esi
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua
			!call >_lua_pushnumber
			!add_esp_byte 0C

			!push_[ebp+byte] 08
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_dword *_g_lua
			!call >_lua_pushnumber
			!add_esp_byte 0C

			!push_byte 00
			!push_byte 00
			!push_byte 00
			!push_byte 00
			!push_byte 02
			!push_dword *_g_lua
			!call >_lua_pcallk
			!add_esp_byte 18

			@ret
			!mov_eax #1
			!restore_stack_frame
			!ret_word 04 00
		]]},
	})

	----------------------------------
	-- New Opcode #501 (ModifyData) --
	----------------------------------

	local IEex_ModifyData = IEex_WriteOpcode({

		["OnAddSpecific"] = {[[

			!push_state
			!mov_eax_[ecx+byte] 44

			; byte ;
			!cmp_eax_byte 01
			!jnz_dword >word

			!xor_eax_eax
			!mov_al_[ecx+byte] 18 ; To Add ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!add_[ecx+edi]_al

			@word
			!cmp_eax_byte 02
			!jne_dword >dword

			!xor_eax_eax
			!mov_ax_[ecx+byte] 18 ; To Add ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!add_[ecx+edi]_ax

			@dword
			!cmp_eax_byte 04
			!jne_dword >ret

			!mov_eax_[ecx+byte] 18 ; To Add ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!add_[ecx+edi]_eax

			@ret
			!mov_eax #1
			!pop_state
			!ret_word 04 00
		]]},


		["OnRemove"] = {[[

			!push_state
			!mov_eax_[ecx+byte] 44

			; byte ;
			!cmp_eax_byte 01
			!jnz_dword >word

			!xor_eax_eax
			!mov_al_[ecx+byte] 18 ; To Subtract ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!sub_[ecx+edi]_al

			@word
			!cmp_eax_byte 02
			!jne_dword >dword

			!xor_eax_eax
			!mov_ax_[ecx+byte] 18 ; To Subtract ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!sub_[ecx+edi]_ax

			@dword
			!cmp_eax_byte 04
			!jne_dword >ret

			!mov_eax_[ecx+byte] 18 ; To Subtract ;
			!mov_edi_[ecx+byte] 1C ; Offset ;
			!mov_ecx_[ebp+byte] 08
			!sub_[ecx+edi]_eax

			@ret
			!mov_eax #1
			!pop_state
			!ret_word 04 00
		]]},
	})

	-----------------------------
	-- Opcode Definitions Hook --
	-----------------------------

	local opcodesHook = IEex_WriteAssemblyAuto(IEex_ConcatTables({[[

		!cmp_eax_dword #1F4
		!jne_dword >501

		]], IEex_InvokeLua, [[

		@501
		!cmp_eax_dword #1F5
		!jne_dword >fail

		]], IEex_ModifyData, [[

		@fail
		!jmp_dword :492C44

	]]}))
	IEex_DisableCodeProtection()
	IEex_WriteAssembly(0x48C882, {{opcodesHook, 4, 4}})
	IEex_EnableCodeProtection()

end)()
