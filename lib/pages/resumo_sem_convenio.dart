import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:totenvalen/model/authToken.dart';
import 'package:totenvalen/model/consulta_response.dart';
import 'package:totenvalen/model/scan_cupom.dart';
import 'package:totenvalen/model/scan_result.dart';
import 'package:totenvalen/model/tarifa.dart';
import 'package:totenvalen/pages/home.dart';

import 'package:totenvalen/pages/pagamento_ok.dart';
import 'package:totenvalen/pages/pagamento_pix.dart';
import 'package:totenvalen/pages/pagamento_select.dart';
import 'package:totenvalen/pages/resumo_sem_convenio_abono.dart';
import 'package:totenvalen/util/modal_transacao_cancelada_function.dart';
import 'package:totenvalen/widgets/header_section_item.dart';
import '../util/modal_cupom_function.dart';
import '../widgets/cancel_button_item.dart';
import '../widgets/real_time_clock_item.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ResumoSemConvenioPage extends StatefulWidget {
  const ResumoSemConvenioPage({Key? key}) : super(key: key);

  @override
  State<ResumoSemConvenioPage> createState() => _ResumoSemConvenioPageState();
}

class _ResumoSemConvenioPageState extends State<ResumoSemConvenioPage> {
  String actualDateTime = DateFormat("HH:mm:ss").format(DateTime.now());
  String enterDate = "";
  String enterHour = "";
  String permanecia = "";
  String placa = "";
  String ticket = "";
  double proportion = 1.437500004211426;
  List<Tarifa> tarifas = [];
  String desconto = "0";
  bool isLoading = true;
  double valorTotal = 0.0;
  Tarifa tarifaTotal = Tarifa(descricao: "Total", valor: 0.0);

  _carregarDados() async {
    final authToken = AuthToken().token;
    var response = await http.get(
      Uri.parse(
          'https://qas.sgpi.valenlog.com.br/api/v1/pdv/caixas/ticket/${ScanResult.result}'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      setState(() {
        if (map['dados']['tarifas'].length > 0) {
          for (dynamic tarifa in map['dados']['tarifas']) {
            String descricao = tarifa['descricao'];
            String stringValor = tarifa['valor'];
            stringValor = stringValor.replaceAll(',', '');
            double valor = double.parse(stringValor);
            print(valor);
            // double valor = double.parse(tarifa['valor']);
            Tarifa novaTarifa = Tarifa(descricao: descricao, valor: valor);
            tarifas.add(novaTarifa);
            tarifaTotal.valor += valor;
            tarifaTotal.descricao = descricao;
            // tarifas.add(tarifa);
          }
        }
        isLoading = false;
        ConsultaResponse.setDescricaoFinal(tarifaTotal.descricao);
        ConsultaResponse.setValorTotal(tarifaTotal.valor);
      });
    } else {
      throw Exception('Erro ao carregar dados');
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assests/fundo.png"),
            fit: BoxFit.cover,
          )),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HeaderSectionItem(
                proportion: proportion,
                actualDateTime: actualDateTime,
                enterHour: ConsultaResponse.enterHour,
                enterDate: ConsultaResponse.enterDate,
                permanecia: ConsultaResponse.permanencia,
                placa: ConsultaResponse.placa,
              ),
              Container(
                // height: (660 / proportion).roundToDouble(),
                width: (1340 / proportion).roundToDouble(),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      (12 / proportion).roundToDouble(),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        "Resumo",
                        style: TextStyle(
                          color: Color(0xFF1A2EA1),
                          fontSize: (72 / proportion).roundToDouble(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.black,
                    ),
                    SizedBox(
                      height: 160,
                      width: (1270 / proportion).roundToDouble(),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tarifa",
                                  style: TextStyle(
                                    fontSize: (48 / proportion).roundToDouble(),
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF132999),
                                  ),
                                ),
                                Text(
                                  "Valor",
                                  style: TextStyle(
                                    fontSize: (48 / proportion).roundToDouble(),
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF132999),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : Column(
                                        children: [
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: tarifas.length,
                                            itemBuilder: (context, index) {
                                              final tarifa = tarifas[index];
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: (16 / proportion)
                                                      .roundToDouble(),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      tarifa.descricao,
                                                      style: TextStyle(
                                                        fontSize: (40 /
                                                                proportion)
                                                            .roundToDouble(),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            Color(0xFF292929),
                                                      ),
                                                    ),
                                                    Text(
                                                      "R\$ ${tarifa.valor}",
                                                      style: TextStyle(
                                                        fontSize: (40 /
                                                                proportion)
                                                            .roundToDouble(),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            Color(0xFF292929),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          )
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: TextStyle(
                              fontSize: (48 / proportion).roundToDouble(),
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF08218C),
                            ),
                          ),
                          Text(
                            "R\$ ${tarifaTotal.valor}",
                            style: TextStyle(
                              fontSize: (48 / proportion).roundToDouble(),
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF292929),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [

                          // CANCELAR OPERAÇÃO
                          SizedBox(
                            width: (620 / proportion).roundToDouble(),
                            height: (152 / proportion).roundToDouble(),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF875E),
                                    Color(0xFFFA6900),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                    (15 / proportion).roundToDouble()),
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  showModalTransacaoCancelada(context);

                                  await Future.delayed(
                                    const Duration(seconds: 2),
                                  );

                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  disabledForegroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.block,
                                      size: (50 / proportion).roundToDouble(),
                                    ),
                                    SizedBox(
                                      width: (24 / proportion).roundToDouble(),
                                      height: (24 / proportion).roundToDouble(),
                                    ),
                                    Text(
                                      "Cancelar",
                                      style: TextStyle(
                                        fontSize:
                                        (48 / proportion).roundToDouble(),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ** ADICIONAR CUPOM - SERÁ HABILITADO FUTURAMENTE QUANDO TIVER ALGUM CUPOM DE TESTE
                          // SizedBox(
                          //   width: (620 / proportion).roundToDouble(),
                          //   height: (152 / proportion).roundToDouble(),
                          //   child: DecoratedBox(
                          //     decoration: BoxDecoration(
                          //       gradient: const LinearGradient(
                          //         colors: [
                          //           Color(0xFFFF875E),
                          //           Color(0xFFFA6900),
                          //         ],
                          //       ),
                          //       borderRadius: BorderRadius.circular(
                          //           (15 / proportion).roundToDouble()),
                          //     ),
                          //     child: ElevatedButton(
                          //       onPressed: scanBarCode,
                          //       style: ElevatedButton.styleFrom(
                          //         backgroundColor: Colors.transparent,
                          //         disabledForegroundColor: Colors.transparent,
                          //         shadowColor: Colors.transparent,
                          //       ),
                          //       child: Row(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: [
                          //           Icon(
                          //             Icons.sticky_note_2_outlined,
                          //             size: (50 / proportion).roundToDouble(),
                          //           ),
                          //           SizedBox(
                          //             width: (24 / proportion).roundToDouble(),
                          //             height: (24 / proportion).roundToDouble(),
                          //           ),
                          //           Text(
                          //             "Adicionar Cupom",
                          //             style: TextStyle(
                          //               fontSize:
                          //                   (48 / proportion).roundToDouble(),
                          //               fontWeight: FontWeight.w600,
                          //               color: Colors.white,
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          // IR PARA PAGAMENTO
                          SizedBox(
                            width: (620 / proportion).roundToDouble(),
                            height: (152 / proportion).roundToDouble(),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF061F89),
                                    Color(0xFF2233AB),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                    (15 / proportion).roundToDouble()),
                              ),
                              child: ElevatedButton(
                                onPressed: liberarSaida,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  disabledForegroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: (50 / proportion).roundToDouble(),
                                    ),
                                    SizedBox(
                                      width: (24 / proportion).roundToDouble(),
                                      height: (24 / proportion).roundToDouble(),
                                    ),
                                    Text(
                                      "Pagamento",
                                      style: TextStyle(
                                        fontSize:
                                            (48 / proportion).roundToDouble(),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RealTimeClockItem(
                    proportion: proportion,
                  ),
                  CancelButtonItem(proportion: proportion),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //método scan
  Future scanBarCode() async {
    try {
      final scanResultCupom = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancelar",
        false,
        ScanMode.BARCODE,
      );
      if (scanResultCupom != '-1') {
        ScanCupom.setResult(scanResultCupom);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResumoSemConvenioAbonoPage()),
        );
      }
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível ler o código de barras')),
      );
    }
  }

  Future<void> liberarSaida() async {
    final authToken = AuthToken().token;

    // // Aguardando a URL de Lucas...
    // final url = Uri.parse(
    //     'https://qas.sgpi.valenlog.com.br/api/v1/pdv/caixas/ticket/baixa/convenio');
    // final request = http.MultipartRequest('POST', url);
    // request.fields['ticket'] = ConsultaResponse.ticket;
    // request.fields['convenio_id'] = ConsultaResponse.convenio_id;
    // request.fields['motorista_cpf'] = StoreCpf.cpf!;
    //
    // // request.headers.addAll({'Authorization': 'Bearer $authToken'});
    // request.headers.addAll({'Authorization': 'Bearer $authToken'});
    // var resposta = await request.send();
    // final respStr = await resposta.stream.bytesToString();
    //
    // Map<String, dynamic> map = jsonDecode(respStr);
    //
    // if (resposta.statusCode == 200) {
    //   FaturadoResponse.setPatio(map["dados"][0]["dados"]["patio"]);
    //   FaturadoResponse.setAtendente(map["dados"][0]["dados"]["atendente"]);
    //   FaturadoResponse.setPlaca(map["dados"][0]["dados"]["placa"]);
    //   FaturadoResponse.setEntrada(map["dados"][0]["dados"]["data_entrada"]);
    //   FaturadoResponse.setPagamento(map["dados"][0]["dados"]["data_pagamento"]);
    //   FaturadoResponse.setPermanencia(map["dados"][0]["dados"]["permancia"]);
    //   FaturadoResponse.setSaidaPermitida(
    //       map["dados"][0]["dados"]["data_saida"]);
    //   FaturadoResponse.setDescricao(
    //       map["dados"][0]["dados"]["detalhes"]["convenio"]);
    //   FaturadoResponse.setMotorista(
    //       map["dados"][0]["dados"]["detalhes"]["motorista"]);
    //   FaturadoResponse.setDinheiro(map["dados"][0]["dados"]["valor_original"]);
    //   FaturadoResponse.setValorReceber(
    //       map["dados"][0]["dados"]["valor_original"]);
    //   FaturadoResponse.setTotalPago(map["dados"][0]["dados"]["totalPago"]);
    //   FaturadoResponse.setTroco(map["dados"][0]["dados"]["troco"]);
    //
    //   if (mounted) {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => PagamentoOKPage(),
    //       ),
    //     );
    //   }
    // } else if (resposta.statusCode == 400) {
    //   if (map['codigo'] == 3004) {
    //     if (mounted) {
    //       showModalCPFIncompativelPlaca(context);
    //     }
    //
    //     await Future.delayed(
    //       const Duration(seconds: 2),
    //     );
    //
    //     if (mounted) {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => CpfInsertPage(),
    //         ),
    //       );
    //     }
    //   }
    // } else {
    //   if (mounted) {
    //     showModalTransacaoNaoAutorizada(context);
    //   }
    //
    //   await Future.delayed(
    //     const Duration(seconds: 2),
    //   );
    //
    //   if (mounted) {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => HomePage(),
    //       ),
    //     );
    //   }
    // }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PagamentoPixPage(),
      ),
    );

  }
}
