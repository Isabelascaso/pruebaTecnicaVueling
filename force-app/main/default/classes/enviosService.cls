@RestResource(urlMapping='/ColaEnvios/*')
global with sharing class enviosService {

    @HttpPost
    global static String doPost() {
        enviosServiceResponse response = new enviosServiceResponse();
        try{
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            String requestString = body.toString();

            Trazabilidad__c traza = new Trazabilidad__c();
            traza.json__c = requestString;
            if(Schema.sObjectType.Trazabilidad__c.isCreateable()){
                insert traza;
            }
    
            enviosServiceRequest requestWrapper = (enviosServiceRequest)JSON.deserialize(requestString,enviosServiceRequest.class);
            System.debug('rw ' +requestWrapper);
            
            Set<String> productSet = new Set<String>();
            response.envios = new List<enviosServiceResponse.envioResponse>();

            for(enviosServiceRequest.envioRequest request : requestWrapper.envios){
                enviosServiceResponse.envioResponse responseActual = comprobarCamposObligatorios(request);
                response.envios.add(responseActual);

                if(responseActual.code_result == 200){
                    productSet.add(request.id_producto);
                }
            }

            Map<String, Id> productCodeIdMap = getProductMap(productSet);
            List<Producto__c> productosCrear = new List<Producto__c>();

            for(String productId : productSet){

                Producto__c producto = new Producto__c();
                if(productCodeIdMap.get(productId) == null){
                    producto.Codigo_de_producto__c = productId;
                    productosCrear.add(producto);
                }

            }

            List<Envio__c> enviosCrear = new List<Envio__c>();
            Integer interator = 0;
            for(enviosServiceRequest.envioRequest request : requestWrapper.envios){
                enviosServiceResponse.envioResponse responseActual= response.envios.get(interator);

                if(responseActual.code_result== 200){
                    enviosCrear.add(crearEnvio( request.id_producto, request, traza));
                }

                interator++;
            }
            
            if(Schema.sObjectType.Producto__c.isCreateable() && productosCrear.size() > 0){
                insert productosCrear;
            }

            if(Schema.sObjectType.Envio__c.isCreateable() && enviosCrear.size() > 0){
                insert enviosCrear;
            }
    
           
        }catch (Exception e){
            System.debug('Exception ' + e);
            System.debug('Exception message' + e.getMessage());
            System.debug('Exception line' + e.getLineNumber());

            for(enviosServiceResponse.envioResponse resp : response.envios){
                resp.code_result = EnvioConstantes.CODEKO500;
                resp.msg_result = e.getMessage();
            }
        }
        
        return JSON.serialize(response);
       
    }

    public static enviosServiceResponse.envioResponse comprobarCamposObligatorios(enviosServiceRequest.envioRequest request){
        Integer code = EnvioConstantes.CODEOK;
        String msg;
        if(request.fecha_envio == null){
            code = EnvioConstantes.CODEKO;
            msg = msg + ' ' +  EnvioConstantes.NOFECHA;
        }
        
        if(request.id_producto == null){
            code = EnvioConstantes.CODEKO;
            msg = msg + ' ' +   EnvioConstantes.NOPRODUCTO;

        }
        
        if(request.descripcion_producto == null){
            code = EnvioConstantes.CODEKO;
            msg = msg + ' ' +   EnvioConstantes.NODESCRIPCION;

        }
        
        if(request.cantidad == null){
            code = EnvioConstantes.CODEKO;
            msg = msg + ' ' +   EnvioConstantes.NOCANTIDAD;

        }
        
        if(request.almacen_destino == null){
            code = EnvioConstantes.CODEKO;
            msg = msg + ' ' +   EnvioConstantes.NOALMACEN;

        }else if(request.almacen_destino != EnvioConstantes.BCN && request.almacen_destino != EnvioConstantes.MAD && request.almacen_destino !=  EnvioConstantes.VLN && request.almacen_destino != EnvioConstantes.SEV){
            code = EnvioConstantes.CODEKO;
            msg = msg + ' ' +   EnvioConstantes.ALMACENINCORRECTO;

        }


        if(msg == null){
            msg = EnvioConstantes.MSGOK;
        }

        enviosServiceResponse.envioResponse response = new enviosServiceResponse.envioResponse();
        response.code_result = code;
        response.msg_result = msg;
        return response;
    }

    public static Map<String, Id> getProductMap(Set<String> productSet){
        Map<String, Id> productCodeIdMap = new Map<String, Id>();
        List<Producto__c> productList = new List<Producto__c>();
        if(Schema.sObjectType.Producto__c.isAccessible()){
            productList = [SELECT id, Codigo_de_producto__c FROM Producto__c WHERE Codigo_de_producto__c IN: productSet];
        }

        for(Producto__c producto : productList){
            productCodeIdMap.put(producto.Codigo_de_producto__c, producto.Id);
        }

        return productCodeIdMap;
    }

    public static Envio__c crearEnvio(String productId, enviosServiceRequest.envioRequest request, Trazabilidad__c traza){
        Producto__c producto = new Producto__c();
        producto.Codigo_de_producto__c = productId;

        Envio__c envio = new Envio__c();
        envio.Fecha_de_envio__c = request.fecha_envio;
        envio.Producto__r = producto;
        envio.Cantidad__c = request.cantidad;
        envio.Almacen_de_destino__c = request.almacen_destino;
        envio.jsonService__c = JSON.serialize(request);
        envio.Descripcion__c = request.descripcion_producto;
        envio.Trazabilidad__c = traza.Id;

        return envio;
    }
    
}