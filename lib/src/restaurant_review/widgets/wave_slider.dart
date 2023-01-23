import 'package:flutter/material.dart';
import 'wave_painter.dart';

class WaveSlider extends StatefulWidget {
  final double sliderHeight;
  final Color? color;
  final ValueChanged<double> onChanged;

  WaveSlider({
    this.sliderHeight = 50.0,
    this.color = Colors.black,
    required this.onChanged,
  });

  @override
  _WaveSliderState createState() => _WaveSliderState();
}

class _WaveSliderState extends State<WaveSlider>
    with SingleTickerProviderStateMixin {
  double? _dragPosition   = 0.0;
  double _dragPercentage = 0.0;
  double? _sliderWidth;

  late WaveSliderController _slideController;


  //region Super ---------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _slideController = WaveSliderController(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _slideController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    RenderBox box = context.findRenderObject() as RenderBox;
    _sliderWidth = box.size.width;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: _sliderWidth,
        height: widget.sliderHeight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: CustomPaint(
            painter: WavePainter(
                color:             widget.color!,
                sliderPosition:    _dragPosition,
                dragPercentage:    _dragPercentage,
                sliderState:       _slideController.state,
                animationProgress: _slideController.progress,
            ),
          ),
        ),
      ),
      onHorizontalDragStart:  (DragStartDetails start)   => _onDragStart(context, start),
      onHorizontalDragUpdate: (DragUpdateDetails update) => _onDragUpdate(context, update),
      onHorizontalDragEnd:    (DragEndDetails end)       => _onDragEnd(context, end),
    );
  }
  //endregion



  //region Private -------------------------------------------------------------
  void _handleChanged(double dragPercentage) {
    assert(widget.onChanged != null);
    double value = (_dragPosition! - (2*5 + 20 + 40)/2)/(_sliderWidth! - (2*5 + 20 + 40));
    if(value < 0) value = 0.0;
    else if(value > 1) value = 5.0;
    else value = value*5;
    widget.onChanged(value*10.floor()/10);
    setState(() {});

  }

  void _onDragStart(BuildContext context, DragStartDetails start) {
    _slideController.setStateToStart();
  }

  void _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    RenderBox box = context.findRenderObject() as RenderBox;

    Offset localOffset = box.globalToLocal(update.globalPosition);
    _slideController.setStateToSliding();
    _updateDragPosition(localOffset);
    _handleChanged(_dragPercentage);
  }

  void _onDragEnd(BuildContext context, DragEndDetails end) {
    _slideController.setStateToStopping();
    setState(() {});
  }

  void _updateDragPosition(Offset val) {
    double? newDragPosition = 0.0;
    if (val.dx <= 0.0) {
      newDragPosition = 0.0;
    } else if (val.dx >= _sliderWidth!) {
      newDragPosition = _sliderWidth;
    } else {
      newDragPosition = val.dx;
    }

    setState(() {
      _dragPosition   = newDragPosition;
      _dragPercentage = _dragPosition! / _sliderWidth!;
    });
  }
  //endregion
}





class WaveSliderController extends ChangeNotifier {

  final AnimationController controller;
  SliderState _state = SliderState.resting;

  WaveSliderController({required TickerProvider vsync})
      : controller = AnimationController(vsync: vsync) {
    controller
      ..addListener(_onProgressUpdate)
      ..addStatusListener(_onStatusUpdate);
  }

  void _onProgressUpdate() {
    notifyListeners();
  }

  void _onStatusUpdate(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _onTransitionCompleted();
    }
  }

  void _onTransitionCompleted() {
    if (_state == SliderState.stopping) {
      setStateToResting();
    }
  }

  double get progress => controller.value;

  SliderState get state => _state;

  void _startAnimation() {
    controller.duration = Duration(milliseconds: 500);
    controller.forward(from: 0.0);
    notifyListeners();
  }

  void setStateToStart() {
    _startAnimation();
    _state = SliderState.starting;
  }

  void setStateToStopping() {
    _startAnimation();
    _state = SliderState.stopping;
  }

  void setStateToSliding() {
    _state = SliderState.sliding;
  }

  void setStateToResting() {
    _state = SliderState.resting;
  }
}

enum SliderState {
  starting,
  resting,
  sliding,
  stopping,
}