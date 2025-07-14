import 'package:flutter/material.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => GuidePageState();
}

class GuidePageState extends State<GuidePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<bool> isPanelOpen = [false, false, false];

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ExpansionPanelList(
        materialGapSize: 10,
        elevation: 1,
        animationDuration: const Duration(milliseconds: 600),
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            isPanelOpen[index] = !isPanelOpen[index];
          });
        },
        children: [
          ExpansionPanel(
              canTapOnHeader: true,
              isExpanded: isPanelOpen[0],
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(
                    "Requisitos básicos",
                    style: textTheme.headlineMedium,
                  ),
                );
              },
              body: const Padding(
                padding: EdgeInsets.only(left: 22, right: 22, bottom: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "\u2022 Estar em boas condições de saúde.",
                    ),
                    Text(
                      "\u2022 Ter entre 16 e 69 anos ,desde que a primeira doação tenha sido feita ate 60 anos (menores de 18 anos verifiquem com o posto de coleta de sua preferencia os documentos necessários e formulário de autorização para doação).",
                    ),
                    Text(
                      "\u2022 Pesar no mínimo 50kg.",
                    ),
                    Text(
                      "\u2022 Ter dormido pelo menos 6h nas ultimas 24h.",
                    ),
                    Text(
                      "\u2022 Alimentação adequada(evitar alimentação gordurosa nas 4h que antecedem a doação).",
                    ),
                    Text(
                      "\u2022 Apresentar documento original com foto emitido por órgão oficial (Carteira de identidade , carteira de habilitação cartão de identidade de profissional liberal, carteira de trabalho e previdência social).",
                    ),
                  ],
                ),
              )),
          ExpansionPanel(
              isExpanded: isPanelOpen[1],
              canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text("Requisitos temporários", style: textTheme.headlineMedium),
                );
              },
              body: const Padding(
                padding: EdgeInsets.only(left: 22, right: 22, bottom: 22),
                child: Text(
                    "\u2022 Ter entre 16 e 69 anos ,desde que a primeira doação tenha sido feita ate 60 anos( menores de 18 anos verifiquem com o posto de coleta de sua preferencia os documentos necessários e formulário de autorização para doação);"),
              )),
          ExpansionPanel(
              isExpanded: isPanelOpen[2],
              canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text("Requisitos definitivos", style: textTheme.headlineMedium),
                );
              },
              body: const Padding(
                padding: EdgeInsets.only(left: 22, right: 22, bottom: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "\u2022 Se estiver resfriado aguardar 7 dias após o desaparecimento dos sintomas.",
                    ),
                    Text(
                      "\u2022 No período de gravidez orienta-se não realizar doação de sangue bem como após o parto , sendo restrito por um período de 90 dias após parto normal e 180 dias após cesariana.",
                    ),
                    Text(
                      "\u2022 Se estiver em período de amamentação.",
                    ),
                    Text(
                      "\u2022 Ingestão de bebida alcoólica nas 12h que antecedem a doação.",
                    ),
                    Text(
                      "\u2022 Se realizou tatuagem nos últimos 6 meses.",
                    ),
                    Text(
                      "\u2022 Situações nas quais ha maior risco de ter contraído IST aguardar por um período de 12 meses.",
                    ),
                    Text(
                      "\u2022 Nos estados do acre, Amapá , Amazonas , Rondônia, Roraima, Maranhão , Mato grosso , Pará , e Tocantins , ha alta prevalência de malária , portanto quem esteve nesses estados deve aguardar 12 meses para doação de sangue.",
                    ),
                    Text(
                      "\u2022 Hepatite medicamentosa (apto após a cura e avaliado clinicamente).",
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
