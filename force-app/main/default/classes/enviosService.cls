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
            Map<String, enviosServiceRequest.envioRequest> productEnviosMap = new Map<String, enviosServiceRequest.envioRequest>();
            for(enviosServiceRequest.envioRequest request : requestWrapper.envios){
                productSet.add(request.id_producto);
                productEnviosMap.put(request.id_producto, request);
            }

            Map<String, Id> productCodeIdMap = getProductMap(productSet);

            List<Producto__c> productosCrear = new List<Producto__c>();
            List<Envio__c> enviosCrear = new List<Envio__c>();
            for(enviosServiceRequest.envioRequest request : requestWrapper.envios){
                Id productCode = productCodeIdMap.get(request.id_producto);

                Producto__c producto = new Producto__c();
                if(productCode == null){
                    producto.Codigo_de_producto__c = request.id_producto;
                    productosCrear.add(producto);
                }else{
                    enviosCrear.add(crearEnvio(productCode, request, traza));
                }


            }
            
            if(Schema.sObjectType.Producto__c.isCreateable()){
                insert productosCrear;
            }

            for(Producto__c producto : productosCrear){
                enviosCrear.add(crearEnvio(producto.id, productEnviosMap.get(producto.Codigo_de_producto__c), traza));
            }

            if(Schema.sObjectType.Envio__c.isCreateable()){
                insert enviosCrear;
            }
    
           
            response.code_result = 200;
            response.msg_result = 'Ok';
        }catch (Exception e){
            System.debug('Exception ' + e);
            System.debug('Exception message' + e.getMessage());
            System.debug('Exception line' + e.getLineNumber());
            response.code_result = 500;
            response.msg_result = e.getMessage();
        }
        
        return JSON.serialize(response);
       
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

    public static Envio__c crearEnvio(Id productId, enviosServiceRequest.envioRequest request, Trazabilidad__c traza){
        Envio__c envio = new Envio__c();
        envio.Fecha_de_envio__c = request.fecha_envio;
        envio.Producto__c = productId;
        envio.Cantidad__c = request.cantidad;
        envio.Almacen_de_destino__c = request.almacen_destino;
        envio.jsonService__c = JSON.serialize(request);
        envio.Descripcion__c = request.descripcion_producto;
        envio.Trazabilidad__c = traza.Id;

        return envio;
    }
    
}