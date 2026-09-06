vim9script

# cwd配下のファイルを列挙する。ディレクトリは除外し、/.git/ 配下のみ無視する。
# これ以外の無視ルールは v1 の割り切りとして入れない。
def Candidates(): list<string>
    var all = map(globpath(getcwd(), '**/*', 0, 1),
        (_, v): string => fnamemodify(v, ':.'))
    return filter(all, (_, v): bool => stridx(v, '/.git/') < 0 && !isdirectory(v))
enddef

# 絞り込み結果 (最大20件)。副作用なし。ランキングは matchfuzzy 任せ。
def View(ctx: dict<any>): list<string>
    if ctx.query ==# ''
        return ctx.all[: 19]
    endif
    return matchfuzzy(ctx.all, ctx.query)[: 19]
enddef

# 先頭行を入力欄、以降を選択肢として描画する。view自体は保持せず都度作り直す。
def Render(ctx: dict<any>, id: number): void
    var view = View(ctx)
    var lines = ['> ' .. ctx.query]
    lines += map(copy(view), (i, v): string => (i == ctx.sel ? '> ' : '  ') .. v)
    if empty(view)
        lines->add('(no match)')
    endif
    popup_settext(id, lines)
enddef

# 全キーを自前で処理し、つねに true を返す (popup側の既定動作に依存しない)。
# j/kを含む印字可能文字はすべてクエリ入力。移動は ↑↓/C-p/C-n のみ。
def Filter(ctx: dict<any>, id: number, key: string): bool
    if key ==# "\<esc>" || key ==# "\<c-c>"
        popup_close(id)
    elseif key ==# "\<cr>"
        var view = View(ctx)
        if !empty(view)
            popup_close(id)
            execute 'edit' fnameescape(view[ctx.sel])
        endif
    elseif key ==# "\<up>" || key ==# "\<c-p>"
        if ctx.sel > 0
            ctx.sel -= 1
            Render(ctx, id)
        endif
    elseif key ==# "\<down>" || key ==# "\<c-n>"
        if ctx.sel < len(View(ctx)) - 1
            ctx.sel += 1
            Render(ctx, id)
        endif
    elseif key ==# "\<bs>" || key ==# "\<c-h>"
        if ctx.query !=# ''
            ctx.query = strcharpart(ctx.query, 0, strchars(ctx.query) - 1)
            ctx.sel = 0
            Render(ctx, id)
        endif
    elseif strchars(key) == 1 && char2nr(key) >= 0x20
        ctx.query ..= key
        ctx.sel = 0
        Render(ctx, id)
    endif
    return true
enddef

export def Open(): void
    var ctx: dict<any> = {query: '', all: Candidates(), sel: 0}
    var id = popup_create([], {
        filter: funcref('Filter', [ctx]),
        border: [],
        padding: [0, 1, 0, 1],
        minwidth: &columns / 2,
        maxheight: &lines / 2,
    })
    Render(ctx, id)
enddef
