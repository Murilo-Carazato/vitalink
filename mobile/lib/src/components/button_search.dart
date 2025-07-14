import 'package:flutter/material.dart';
import 'package:vitalink/services/stores/blood_center_store.dart';

class MySearchBar extends StatefulWidget {
  final BloodCenterStore bloodCenterStore;
  final TextEditingController controller;
  const MySearchBar({super.key, required this.controller, required this.bloodCenterStore});

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> with SingleTickerProviderStateMixin {
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.bloodCenterStore.isSearchMode]),
      builder: (context, child) => Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!widget.bloodCenterStore.isSearchMode.value) Text("Hemocentros", style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 24, fontWeight: FontWeight.w600)),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                child: widget.bloodCenterStore.isSearchMode.value
                    ? TextFormField(
                        focusNode: focusNode,
                        controller: widget.controller,
                        decoration: InputDecoration(
                            hintText: 'Encontre um hemocentro',
                            contentPadding: EdgeInsets.zero,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                                onPressed: () async {
                                  widget.bloodCenterStore.isSearchMode.value = false;
                                  widget.controller.text = '';
                                  widget.bloodCenterStore.page.value = 1;
                                  await widget.bloodCenterStore.index(true, '');
                                },
                                icon: const Icon(Icons.close))),
                        onFieldSubmitted: (value) async {
                          await widget.bloodCenterStore.index(false, widget.controller.text.toLowerCase());
                        },
                      )
                    : IconButton(
                        onPressed: () {
                          setState(() => widget.bloodCenterStore.isSearchMode.value = true);
                          focusNode.requestFocus();
                        },
                        icon: const Icon(Icons.search)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
