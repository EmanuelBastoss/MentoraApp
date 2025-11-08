import 'package:flutter/material.dart';
import 'package:mentoraapp/services/auth/auth_service.dart';
import 'package:mentoraapp/componentes/my_button.dart';
import 'package:mentoraapp/componentes/my_textfield.dart';

class RegisterPage extends StatelessWidget {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

   RegisterPage({super.key,
   required this.onTap});

  final void Function()? onTap;
   void register(BuildContext context) async{
    final _auth = AuthService();

    
  if(_pwController.text == _confirmPwController.text){
      try {_auth.signUpWithEmailPassword(_emailController.text, _pwController.text);
  
   } catch (e){
      showDialog(context: context, builder: (context)=> AlertDialog(  
      title: Text(e.toString()),
    ));
    }} else{
    showDialog(context: context, builder: (context)=> AlertDialog(  
      title: Text("Senhas nao coincidem"),
    ));
   }}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(  context).colorScheme.background,
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Icon(Icons.message,
          size: 60,
          color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 50),
        Text(
          "Crie sua conta.",
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,

          ),

        

        ),
        
          const SizedBox(height: 25),
          
          MyTextField(
            hintText: "Email",
            obscureText: false,
            controller: _emailController,
          ),
          const SizedBox(height: 10),
          MyTextField(
            hintText: "Senha",
            obscureText: true,
            controller: _pwController,
          ),
          const SizedBox(height: 10),
          MyTextField(
            hintText: "Confirme a senha",
            obscureText: true,
            controller: _confirmPwController,
          ),
          const SizedBox(height: 25),

          MyButton(text: "Register",
          onTap: () => register(context),
          ),

          const SizedBox(height: 25,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Ja tem uma conta? ",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),),
              GestureDetector(
                onTap: onTap,
                child: Text("Entre", style: TextStyle(fontWeight: FontWeight.bold),)),
            ],
          ),

        ]
            ),
          ),
    
      
    );
  }
}