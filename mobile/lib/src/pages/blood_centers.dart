import 'package:flutter/material.dart';
import 'package:vitalink/services/models/blood_center_model.dart';
import 'package:vitalink/services/models/page_model.dart';
import 'package:vitalink/services/stores/blood_center_store.dart';
import 'package:vitalink/src/components/blood_center_card_with_options.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BloodCentersPage extends StatefulWidget {
  final BloodCenterStore bloodCenterStore;
  const BloodCentersPage({super.key, required this.bloodCenterStore});

  @override
  State<BloodCentersPage> createState() => _BloodCentersPageState();
}

class _BloodCentersPageState extends State<BloodCentersPage> {
  late List<BloodCenterModel> bloodCenters;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.bloodCenterStore.index(true, '');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.bloodCenterStore.page,
          widget.bloodCenterStore.pages,
          widget.bloodCenterStore.state,
          widget.bloodCenterStore.stateWhenPaginate,
          widget.bloodCenterStore.isLoading,
          widget.bloodCenterStore.erro,
          widget.bloodCenterStore.isSearchMode,
        ]),
        builder: (context, child) {
          if (widget.bloodCenterStore.erro.value.isNotEmpty) {
            return Text(widget.bloodCenterStore.erro.value, style: Theme.of(context).textTheme.displayMedium!.copyWith(color: Theme.of(context).primaryColor));
          }
          return Flex(
            direction: Axis.vertical,
            children: [
              Skeletonizer(
                key: ValueKey(widget.bloodCenterStore.page.value),
                enabled: widget.bloodCenterStore.isLoading.value,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  controller: ScrollController(),
                  itemCount: widget.bloodCenterStore.stateWhenPaginate.value.length,
                  itemBuilder: (context, index) {
                    final bloodCenter = widget.bloodCenterStore.stateWhenPaginate.value[index];

                    return BloodCenterCardWithOptions(
                      key: ValueKey('BloodCenter.${bloodCenter.id}'),
                      bloodCenter: bloodCenter,
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              // Text(widget.bloodCenterStore.page.value.toString()),

              //Widget para quando usuário não estiver pesquisando hemocentro
              Visibility(
                visible: !(widget.bloodCenterStore.isSearchMode.value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: SizedBox(
                    height: 35,
                    child: ListView.builder(
                      shrinkWrap: true,
                      prototypeItem: child,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.bloodCenterStore.pages.value.length,
                      itemBuilder: (context, index) {
                        //Percorre lista de páginas fazendo com que cada índice se torne um PageModel.
                        //Quando o índice é igual ao índice da página atual, o botão fica ativo.
                        //Caso contrário, o botão fica desativado.
                        //Quando o botão é pressionado, é feita a requisição com provider com o índice do botão pressionado + 1.
                        //Quando a requisição termina, é feita a atualização da lista de hemocentros.
                        //Quando a lista de páginas é atualizada, é feita a atualização do indicador de página atual.
                        //Quando o indicador de página atual é atualizado, é feita a atualização da lista de hemocentros.
                        //Quando a lista de hemocentros é atualizada, é feita a atualização da lista de páginas, afinal, o índice em que se encontrava o status "Active" foi alterado.
                        PageModel page = widget.bloodCenterStore.pages.value[index];

                        return Padding(
                          key: ValueKey(page),
                          padding: const EdgeInsets.only(right: 5),
                          child: ElevatedButton(
                            style: page.active ? ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white) : null,
                            onPressed: widget.bloodCenterStore.isLoading.value
                                ? null
                                : () async {
                                    if (!page.active) {
                                      //Página atual da api recebe o índice atual + 1
                                      widget.bloodCenterStore.page.value = page.label;

                                      //Realiza requisição com provider
                                      await widget.bloodCenterStore.index(true, '');
                                    }
                                  },
                            child: Text('${page.label}'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          );
        },
      ),
    );
  }
}
