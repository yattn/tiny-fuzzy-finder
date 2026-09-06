vim9script
# tiny-fuzzy-finder の自動テスト。列挙・絞り込み・移動・確定・取消を見る。
# filterは popup_getoptions() 経由で直接駆動する (キー入力の代わり)。
# キーの手触り確認は test.sh の手動起動が担当。
#
# 実行 (repo root から): vim -n -es --cmd "set rtp+=$PWD" -S test/check.vim < /dev/null; echo $?
# rtpは絶対パスで渡す (テスト内でcdするため相対パスは不可)。
# 成功時 exit 0、失敗時 exit 非ゼロ。

if !exists(':Tff')
    echoerr 'FAIL: :Tff not defined (run from repo root with --cmd "set rtp+=$PWD")'
    cquit
endif

var failures: list<string> = []

def Ok(cond: bool, msg: string): void
    if !cond
        failures->add('FAIL: ' .. msg)
    endif
enddef

def PopupId(): number
    var ids = popup_list()
    Ok(len(ids) == 1, 'exactly one popup, got ' .. string(len(ids)))
    return empty(ids) ? 0 : ids[0]
enddef

# 注: 引数名はスクリプト変数と衝突不可 (E1168)。var id があるため pid を使う。
def Lines(pid: number): list<string>
    return getbufline(winbufnr(pid), 1, '$')
enddef

def Strip(lines: list<string>): list<string>
    return map(copy(lines), (_, v): string => v[2 :])
enddef

def TryTff(): void
    try
        Tff
    catch
        failures->add('FAIL: Tff: ' .. v:exception)
    endtry
enddef

execute 'cd' fnameescape('test/fixture')
# .git配下の除外を見るためだけに作る (gitは '.git' を含むパスを管理できないため動的生成)。
mkdir('.git', 'p')
writefile(['ignored'], '.git/ignored.txt')

# 1. 初期表示: ファイルのみ (ディレクトリと.git配下を除外)、先頭行に '> ' マーカー
TryTff()
var id = PopupId()
if id != 0
    try
        var init = Lines(id)
        Ok(len(init) == 2 && sort(Strip(init)) == ['a.txt', 'sub/b.txt'],
            'lists files only: ' .. string(init))
        Ok(len(init) == 2 && init[0][: 1] ==# '> ' && init[1][: 1] ==# '  ',
            'marker on first line only: ' .. string(init))
        delete('.git', 'rf')

        # 2. 入力で絞り込み ('b' を含むのは sub/b.txt のみ)、タイトルにクエリ表示
        var F: any = popup_getoptions(id).filter
        call(F, [id, 'b'])
        var narrowed = Lines(id)
        Ok(narrowed == ['> sub/b.txt'], 'narrows to match: ' .. string(narrowed))
        Ok(popup_getoptions(id).title ==# '> b', 'query in title')

        # 3. BSで復帰
        call(F, [id, "\<bs>"])
        Ok(Lines(id) == init, 'BS restores list')

        # 4. ↓/↑でマーカー移動
        call(F, [id, "\<down>"])
        var moved = Lines(id)
        Ok(len(moved) == 2 && moved[0][: 1] ==# '  ' && moved[1][: 1] ==# '> ',
            'down moves marker: ' .. string(moved))
        call(F, [id, "\<up>"])
        Ok(Lines(id) == init, 'up restores marker')

        # 5. Enterで先頭行のファイルを開く
        var first = empty(init) ? '' : Strip(init)[0]
        call(F, [id, "\<cr>"])
        Ok(empty(popup_list()), 'enter closes popup')
        Ok(expand('%:.') ==# first, 'enter opens selected: ' .. expand('%:.') .. ' != ' .. first)

        # 6. Escで閉じる (バッファは変わらない)
        TryTff()
        id = PopupId()
        if id != 0
            F = popup_getoptions(id).filter
            var before = expand('%:.')
            call(F, [id, "\<esc>"])
            Ok(empty(popup_list()), 'esc closes popup')
            Ok(expand('%:.') ==# before, 'esc keeps buffer')
        endif
    catch
        failures->add('FAIL: drive filter: ' .. v:exception)
    endtry
endif

# 7. 表示は20件固定
var saved = getcwd()
var dir = tempname()
mkdir(dir, 'p')
for i in range(1, 25)
    writefile(['x'], dir .. '/f' .. printf('%02d', i) .. '.txt')
endfor
execute 'cd' fnameescape(dir)
TryTff()
id = PopupId()
if id != 0
    Ok(len(Lines(id)) == 20, 'shows 20 lines max')
endif
popup_clear()
execute 'cd' fnameescape(saved)
delete(dir, 'rf')

# 失敗詳細はechoerr+終了コードで返す。writefile(/dev/stderr)はopenを伴い、
# 書けない環境では例外→Ex放置→ハングするため使わない。詳しくは -V ログで。
if empty(failures)
    qa!
endif
echoerr join(failures, "\n")
cquit
