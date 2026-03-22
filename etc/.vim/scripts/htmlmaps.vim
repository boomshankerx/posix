" TIDY
nmap <F12>		:%!tidy -config ~/.vim/tidy<CR><CR>
nmap <S-f12>	:%!tidy -config ~/.vim/tidy-frag<CR><CR>
nmap <C-f12>	:%!tidy -config ~/.vim/tidy-fragwrap<CR><CR>

nmap \th			:%!tidy -config ~/.vim/tidy-html5<CR><CR>
nmap \tf			:%!tidy -config ~/.vim/tidy-html5-frag<CR><CR>

nmap <F11>		:%!csstidy - --lowercase_s=true --sort_selectors=true --sort_properties=true --silent=true --compress_colors=true --case_properties=1 --compress_font-weight=false --template=low<CR><CR>
nmap <S-F11>	:%!csstidy - --lowercase_s=true --sort_selectors=true --sort_properties=true --silent=true --compress_colors=true --case_properties=1 --compress_font-weight=false --template=high<CR><CR>
nmap <C-F11>	:%!csstidy - --lowercase_s=true --sort_selectors=true --sort_properties=true --silent=true --compress_colors=true --case_properties=1 --compress_font-weight=false --template=highest<CR><CR>

nmap <F9>		V!boxes -f ~/.vim/boxes -d hash<CR>
nmap <S-F9>	V!boxes -f ~/.vim/boxes -d hash-slash<CR> 
nmap <C-F9>	V!boxes -f ~/.vim/boxes -d hash-vim<CR>

vmap <F9>		!boxes -f ~/.vim/boxes -d hash<CR>
vmap <S-F9>	!boxes -f ~/.vim/boxes -d hash-slash<CR> 
vmap <C-F9>	!boxes -f ~/.vim/boxes -d hash-vim<CR>

nmap <F8>		:%! php ~/.vim/beautify.php<CR>
