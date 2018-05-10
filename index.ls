angular.module \main, <[ui.choices]>
  ..directive \ngIonSlider, <[$compile]> ++ ($compile) -> do
    restrict: \A
    scope: do
      model: \=ngValue
      config: \=config
    link: (s,e,a,c) ->
      config = s.config or {}
      isDouble = config.type == \double
      if isDouble and !Array.isArray(s.model) => s.model = [0,100]
      s.$watch 'config', ((config) -> slider.update(config)), true
      s.$watch 'model', ->
        if isDouble =>
          if slider.result.from != it.0 => slider.update({from: it.0})
          if slider.result.to != it.1 => slider.update({to: it.1})
        else
          if slider.result.from != +it => slider.update({from: it})
      $(e).ionRangeSlider {} <<< config <<< do
        onChange: (v) -> s.$apply ->
          if isDouble =>
            if s.model.0  != v.from => s.model.0 = v.from
            if s.model.1  != v.to => s.model.1 = v.to
          else if s.model != v.from => s.model = v.from
      slider = $(e).data \ionRangeSlider

  ..controller \main, <[$scope $interval]> ++ ($scope, $interval) ->
    $scope.nodes = []
    $scope.track-event = (cat, act, label, value) -> ga \send, \event, cat, act, label, value
    $scope.scrollto = (sel = null,delay=0) ->
      <- setTimeout _, delay
      top = if sel => ( $(sel).offset!top - 60 ) else 0
      $(document.body).animate {scrollTop: top}, '500', 'swing', ->
      $("html").animate {scrollTop: top}, '500', 'swing', ->
    $scope.item-count = do
      config: do
        min: 10
        max: 200
        hide_min_max: true
        hide_from_to: true
        grid: false
      value: 10
    $scope.$watch 'itemCount.value', -> $scope.init!

    $scope <<< do
      randomWidth: false
      randomHeight: false
    $scope.init = ->
      $scope.nodes = [{
        w: if $scope.randomWidth => (Math.random!*110 + 20) else 30
        h: if $scope.randomHeight => (Math.random!*50 + 10) else 30
        p: Math.floor(Math.random! * 6) + 1
      } for i from 0 to ($scope.item-count.value)]
    $scope.$watch 'randomHeight', $scope.init
    $scope.$watch 'randomWidth', $scope.init
    $scope.init!

    $scope.modal = do
      css: toggled: false, toggle: (v) ->
        @toggled = if v => v else !!!@toggled
        if @toggled => $scope.track-event \flexbox, \get, \css

    clipboard = new Clipboard '*[data-clipboard-target]'
    clipboard.on \success, (e) ->
      $(e.trigger).tooltip({title: 'copied', trigger: 'click'}).tooltip('show')
      setTimeout((->$(e.trigger).tooltip('hide')), 1000)
    clipboard.on \error, (e)->
      $(e.trigger).tooltip({title: 'Press Ctrl+C to Copy', trigger: 'click'}).tooltip('show')
      setTimeout((->$(e.trigger).tooltip('hide')), 1000)

    direction = ->
      $scope.flexdirection = $scope.direction + if $scope.directionReverse => "-reverse" else ""
    $scope.$watch 'direction', direction
    $scope.$watch 'directionReverse', direction
    pseudocss = """
      .container:after {
        display: block;
        content: " invisible node ";
        flex: 999 999 auto;
      }
    """
    $scope.margin = do
      value: 5
      config: min: 0, max: 100
    $scope.flex = do
      grow: value: 0, auto: false, config: min: 0, max: 100
      shrink: value: 0, auto: false, config: min: 0, max: 100
      basis: value: 0, auto: true, config: min: 0, max: 1000
      get: ->
        g = if @grow.auto => "auto" else @grow.value
        s = if @shrink.auto => "auto" else @shrink.value
        b = if @basis.auto => "auto" else @basis.value
        return "flex: #g #s #b"
    $scope.$watch 'flex.grow.auto', -> $scope.flex.grow.config.disable = it
    $scope.$watch 'flex.shrink.auto', -> $scope.flex.shrink.config.disable = it
    $scope.$watch 'flex.basis.auto', -> $scope.flex.basis.config.disable = it
    $scope.update = ->
      $scope.css = do
        container: """
          min-height: 400px;
            display: flex;
            display: -webkit-flex;
            flex-wrap: #{$scope.wrapping.0};
            flex-direction: #{$scope.flexdirection};
            justify-content: #{$scope.justify.0};
            align-items: #{$scope.align.0};
            align-content: #{$scope.multialign.0};
        """
        item: """
          #{$scope.flex.get!};
            margin: #{$scope.margin.value}px;
        """

      $scope.output = """
        .container {
          #{$scope.css.container}
        }
        #{if $scope.invisible-item => pseudocss else ''}
        .item {
          #{$scope.css.item}
        }
      """
      resize!
    $scope.tags = <[Lorem ipsum dolor sit amet consectetuer adipiscing elit Aenean commodo ligula eget dolor Aenean massa Cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus Donec quam felis ultricies nec pellentesque eu pretium quis sem Nulla consequat massa quis enim Donec pede justo fringilla vel aliquet nec vulputate eget arcu In enim justo rhoncus ut imperdiet a venenatis vitae justo Nullam dictum felis eu pede mollis pretium Integer tincidunt Cras dapibus Vivamus elementum semper nisi Aenean vulputate eleifend tellus Aenean leo ligula porttitor eu consequat vitae eleifend ac enim Aliquam lorem ante dapibus in viverra quis feugiat a tellus Phasellus viverra nulla ut metus varius laoreet Quisque rutrum Aenean imperdiet Etiam ultricies nisi vel augue Curabitur ullamcorper ultricies nisi Nam eget dui Etiam rhoncus Maecenas tempus tellus eg]>

    resize = ->
      document.querySelector \#preview .style
        ..width = "#{window.innerWidth - 550}px"
      document.querySelector '#root .detail' .style
        ..width = "#{window.innerWidth - 550}px"
    window.addEventListener \resize, resize
    $interval (-> $scope.update! ), 500
