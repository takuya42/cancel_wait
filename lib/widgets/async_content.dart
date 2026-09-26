import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncContent<T> extends StatelessWidget {
  const AsyncContent({required this.value,required this.builder,super.key}); final AsyncValue<T> value; final Widget Function(T) builder;
  @override Widget build(BuildContext context)=>value.when(data:builder,loading:()=>const Center(child:Padding(padding:EdgeInsets.all(48),child:CircularProgressIndicator())),error:(e,_)=>Center(child:Padding(padding:const EdgeInsets.all(32),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.cloud_off_outlined,size:48),const SizedBox(height:12),const Text('データを読み込めませんでした'),const SizedBox(height:6),Text('$e',textAlign:TextAlign.center,style:Theme.of(context).textTheme.bodySmall)]))));
}
