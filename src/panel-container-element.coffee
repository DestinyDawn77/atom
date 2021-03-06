{CompositeDisposable} = require 'event-kit'

class PanelContainerElement extends HTMLElement
  createdCallback: ->
    @subscriptions = new CompositeDisposable

  initialize: (@model, {@views}) ->
    throw new Error("Must pass a views parameter when initializing PanelContainerElements") unless @views?

    @subscriptions.add @model.onDidAddPanel(@panelAdded.bind(this))
    @subscriptions.add @model.onDidDestroy(@destroyed.bind(this))
    @classList.add(@model.getLocation())
    this

  getModel: -> @model

  panelAdded: ({panel, index}) ->
    panelElement = @views.getView(panel)
    panelElement.classList.add(@model.getLocation())
    if @model.isModal()
      panelElement.classList.add("overlay", "from-top")
    else
      panelElement.classList.add("tool-panel", "panel-#{@model.getLocation()}")

    if index >= @childNodes.length
      @appendChild(panelElement)
    else
      referenceItem = @childNodes[index]
      @insertBefore(panelElement, referenceItem)

    if @model.isModal()
      @hideAllPanelsExcept(panel)
      @subscriptions.add panel.onDidChangeVisible (visible) =>
        @hideAllPanelsExcept(panel) if visible

  destroyed: ->
    @subscriptions.dispose()
    @parentNode?.removeChild(this)

  hideAllPanelsExcept: (excludedPanel) ->
    for panel in @model.getPanels()
      panel.hide() unless panel is excludedPanel
    return

module.exports = PanelContainerElement = document.registerElement 'atom-panel-container', prototype: PanelContainerElement.prototype
