{BufferedProcess} = require 'atom'

module.exports =
  activate: ->
    atom.workspaceView.command "execute-as-ruby:execute", => @execute()

  execute: ->
    # This assumes the active pane item is an editor
    editor = atom.workspace.activePaneItem
    cursor = editor.getCursor()
    selection = editor.getSelectedText()

    insertResult = (result) ->
        editor.moveCursorToEndOfLine()
        editor.insertText(" " + result)

    if not selection
        line = cursor.getCurrentBufferLine()
        result = @runRuby(line, insertResult)
    else
        result = @runRuby(selection, insertResult)

  packagePath: ->
    packagePath = null
    for p in atom.packages.getAvailablePackagePaths()
        if p.indexOf("/execute-as-ruby") != -1
            packagePath = p
    if not packagePath
        throw "Could not locate package path"
    packagePath

  runRuby: (rubyCode, done) ->
      command = 'ruby'
      args = ['--', @packagePath() + "/lib/helper.rb", rubyCode
      output = []
      stdout = (data) -> output.push(data)
      exit = (code) -> done(output.join(""))
      stderr = (data) -> output.push(data)
      process = new BufferedProcess({command, args, stdout, stderr, exit})
